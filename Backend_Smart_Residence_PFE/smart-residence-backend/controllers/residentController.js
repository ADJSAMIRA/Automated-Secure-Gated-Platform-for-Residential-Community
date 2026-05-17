const ResidentModel = require('../models/residentModel'); 
const AdminModel = require('../models/adminModel');
const NotificationModel = require('../models/notificationModel');

//  RESIDENT PROFILE AND DASHBOARD

exports.getResidentProfile = async (req, res) => {
    const userId = req.params.id; 
    try {
        const user = await ResidentModel.getUserProfile(userId);
        if (!user) {
            return res.status(404).json({ success: false, message: "Resident not found" });
        }
        res.json({ success: true, data: user });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

exports.getStats = async (req, res) => {
    const userId = req.params.id; 
    try {
        const stats = await ResidentModel.getResidentStats(userId);
        res.json({ success: true, data: stats });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};


//  EVENT MANAGEMENT

exports.createEvent = async (req, res) => {
    try {
        const { title, description, eventDate, time, endTime, isPublic, invitedUsers, organizer_id } = req.body;

        if (!isPublic && invitedUsers && invitedUsers.length > 50) {
            return res.status(400).json({ message: "Event Hall maximum capacity is 50. You cannot invite more people." });
        }

        const isOverlapping = await ResidentModel.checkEventOverlap(eventDate, time, endTime);
        if (isOverlapping) {
            return res.status(400).json({ message: "Time slot already taken by another event!" });
        }

        const [result] = await ResidentModel.createEvent({ title, description, eventDate, time, endTime, isPublic, organizer_id });
        const eventId = result.insertId;

        if (!isPublic && invitedUsers && invitedUsers.length > 0) {
            await ResidentModel.addInvites(eventId, invitedUsers);
        }

        const adminId = await ResidentModel.getActiveAdminId();

        await NotificationModel.create({
            user_id: adminId, 
            title: "New Event Approval Request",
            message: `A resident has requested to create an event titled: "${title}". Please review and approve it.`,
            type: "Event"
        });

        res.status(201).json({ message: "Event created and is pending Admin approval!" });
    } catch (error) {
        console.error("Error in createEvent:", error);
        res.status(500).json({ error: error.message });
    }
};

exports.updateEvent = async (req, res) => {
    const eventId = req.params.id;
    const { title, description, eventDate, time, endTime, isPublic, userId, organizer_id } = req.body; 
    const currentUserId = userId || organizer_id; 

    try {
        const oldEvent = await ResidentModel.getEventById(eventId);
        
        if (!oldEvent) {
            return res.status(404).json({ success: false, message: "Event not found" });
        }

        if (Number(oldEvent.organizer_id) !== Number(currentUserId)) {
            return res.status(403).json({ success: false, message: "Unauthorized to edit this event" });
        }

        const isTimeChanged = (oldEvent.eventDate !== eventDate) || 
                             (oldEvent.time !== time) || 
                             (oldEvent.endTime !== endTime);
        
        if (isTimeChanged) {
            const isOverlapping = await ResidentModel.checkEventOverlap(eventDate, time, endTime, eventId);
            if (isOverlapping) {
                return res.status(400).json({ success: false, message: "Time slot already taken by another event!" });
            }
        }

        const updatedData = { title, description, eventDate, time, endTime, isPublic };
        await ResidentModel.updateEvent(eventId, updatedData);

        let statusMessage = "Event updated successfully.";
        if (isTimeChanged) {
            await ResidentModel.revertEventToPending(eventId);
            statusMessage = "Event updated. Status reverted to Pending because time/date changed.";
        }

        res.json({ success: true, message: statusMessage });

    } catch (error) {
        console.error("Update Event Error:", error);
        res.status(500).json({ success: false, message: error.message });
    }
};

exports.deleteEvent = async (req, res) => {
    try {
        const { userId, organizer_id } = req.body;
        const currentUserId = userId || organizer_id;
        const event = await ResidentModel.getEventById(req.params.id);

        if (!event) return res.status(404).json({ message: "Event not found" });

        if (Number(event.organizer_id) !== Number(currentUserId)) {
            return res.status(403).json({ message: "Unauthorized!" });
        }

        await ResidentModel.deleteEvent(req.params.id);
        res.json({ message: "Event deleted successfully!" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};



exports.joinEvent = async (req, res) => {
    try {
        const { eventId, userId } = req.body; 

        const event = await ResidentModel.getEventById(eventId);
        
        if (!event) return res.status(404).json({ message: "Event not found" });
        if (event.status !== 'Approved') return res.status(400).json({ message: "Event is not approved yet" });

        const result = await ResidentModel.joinAnyEvent(eventId, userId, event.isPublic);

        if (!result.success) {
            if (result.reason === 'full') {
                return res.status(400).json({ message: "Event is Full! (Maximum 50 participants reached)" });
            }
            if (result.reason === 'exists') {
                return res.status(400).json({ message: "You have already joined this event!" });
            }
            if (result.reason === 'not_invited') {
                return res.status(403).json({ message: "This is a private event and you are not invited." });
            }
        }

        res.json({ success: true, message: "Successfully joined the event!" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.getParticipants = async (req, res) => {
    try {
        const participants = await ResidentModel.getEventParticipants(req.params.id);
        res.json(participants);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.listEvents = async (req, res) => {
    try {
        const events = await ResidentModel.getAllEvents(req.query.userId);
        res.json(events);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.getUpcomingEvents = async (req, res) => {
    try {
        const events = await AdminModel.getApprovedEvents(); 
        res.json(events); 
    } catch (error) {
        console.error("Error in getUpcomingEvents:", error);
        res.status(500).json({ success: false, error: error.message });
    }
};


// RESERVATIONS

exports.getSharedSpaces = async (req, res) => {
    try {
        const spaces = await ResidentModel.getSharedSpaces();
        res.status(200).json(spaces);
    } catch (error) {
        console.error("Get Shared Spaces Error:", error);
        res.status(500).json({ success: false, message: error.message });
    }
};

exports.createReservation = async (req, res) => {
    try {
        const { id_space, id_user, reservationDate, startTime, endTime } = req.body;

        if (!id_space || !id_user) {
            return res.status(400).json({ success: false, message: "Missing required fields (id_space or id_user)" });
        }

        const space = await ResidentModel.getSpaceDetails(id_space);
        if (!space) {
            return res.status(404).json({ success: false, message: "Shared space not found" });
        }

        if (startTime < space.openTime || endTime > space.closeTime) {
            return res.status(400).json({ 
                success: false, 
                message: `Invalid time. This space is only open from ${space.openTime} to ${space.closeTime}.` 
            });
        }

        const currentBookedSpots = await ResidentModel.getBookedSpotsCount(id_space, reservationDate, startTime, endTime);

        if (currentBookedSpots >= space.capacity) {
            return res.status(400).json({ 
                success: false, 
                message: "Sorry, this space is fully booked for the selected time." 
            });
        }

        await ResidentModel.createReservation(id_space, id_user, reservationDate, startTime, endTime);
        
        const spaceName = space.name || "Shared Space";

        await NotificationModel.create({
            user_id: id_user, 
            title: "Reservation Confirmed Successfully",
            message: `Your booking for "${spaceName}" on ${reservationDate} from ${startTime} to ${endTime} has been confirmed.`,
            type: "Reservation"
        });
        
        res.status(201).json({ success: true, message: "Reservation confirmed successfully!" });

    } catch (error) {
        console.error("Create Reservation Error:", error);
        res.status(500).json({ success: false, message: error.message });
    }
};

exports.updateReservation = async (req, res) => {
    try {
        const reservationId = req.params.id;
        const { space_id, reservationDate, startTime, endTime, userId } = req.body;

        const existingReservation = await ResidentModel.getReservationById(reservationId);
        if (!existingReservation) {
            return res.status(404).json({ success: false, message: "Reservation not found" });
        }
        if (existingReservation.user_id != userId) {
            return res.status(403).json({ success: false, message: "Unauthorized" });
        }

        const space = await ResidentModel.getSpaceDetails(space_id);
        if (!space) {
            return res.status(404).json({ success: false, message: "Shared space not found" });
        }

        if (startTime < space.openTime || endTime > space.closeTime) {
            return res.status(400).json({ 
                success: false, 
                message: `Update failed. This space is only open from ${space.openTime} to ${space.closeTime}.` 
            });
        }

        const currentBookedSpots = await ResidentModel.getBookedSpotsCount(space_id, reservationDate, startTime, endTime, reservationId);

        if (currentBookedSpots >= space.capacity) {
            return res.status(400).json({ 
                success: false, 
                message: "Update failed. The new time slot is fully booked." 
            });
        }

        await ResidentModel.updateReservation(reservationId, space_id, reservationDate, startTime, endTime);
        res.json({ success: true, message: "Reservation time updated successfully!" });

    } catch (error) {
        console.error("Update Reservation Error:", error);
        res.status(500).json({ success: false, message: error.message });
    }
};

exports.deleteReservation = async (req, res) => {
    try {
        const reservationId = req.params.id;
        const { userId } = req.body; 

        const existingReservation = await ResidentModel.getReservationById(reservationId);
        if (!existingReservation) {
            return res.status(404).json({ success: false, message: "Reservation not found" });
        }
        if (existingReservation.user_id != userId) {
            return res.status(403).json({ success: false, message: "Unauthorized" });
        }

        await ResidentModel.deleteReservation(reservationId);
        res.json({ success: true, message: "Reservation canceled successfully!" });

    } catch (error) {
        console.error("Delete Reservation Error:", error);
        res.status(500).json({ success: false, message: error.message });
    }
};

exports.getUpcomingReservations = async (req, res) => {
    try {
        const userId = req.params.userId; 
        const reservations = await ResidentModel.getUpcomingReservations(userId);
        res.json({ success: true, data: reservations });
    } catch (error) {
        console.error("Fetch Reservations Error:", error);
        res.status(500).json({ success: false, message: error.message });
    }
};

exports.getSpaceAvailability = async (req, res) => {
    try {
        const spaceId = req.params.spaceId;
        const date = req.query.date; 

        if (!date) {
            return res.status(400).json({ success: false, message: "Date is required" });
        }

        const bookedTimes = await ResidentModel.getSpaceBookingsByDate(spaceId, date);
        const space = await ResidentModel.getSpaceDetails(spaceId);

        if (!space) {
            return res.status(404).json({ success: false, message: "Space not found" });
        }

        res.json({ 
            success: true, 
            capacity: space.capacity,
            openTime: space.openTime,
            closeTime: space.closeTime,
            bookedTimes: bookedTimes 
        });

    } catch (error) {
        console.error("Availability Error:", error);
        res.status(500).json({ success: false, message: error.message });
    }
};


// ALERTS AND MAINTENANCE

exports.reportAlert = async (req, res) => {
    try {
        const { title, description, category, source, reportedBy_id, urgencyLevel } = req.body;

        if (!title || !description || !category || !source || !reportedBy_id || !urgencyLevel) {
            return res.status(400).json({ success: false, message: "Please fill all required fields." });
        }

        await ResidentModel.createAlert({
            title, description, category, source, reportedBy_id, urgencyLevel
        });

        const adminId = await ResidentModel.getActiveAdminId();

        await NotificationModel.create({
            user_id: adminId, 
            title: `New Maintenance Alert (${urgencyLevel})`,
            message: `A new issue has been reported in the (${category}) category titled: "${title}". Please review it and assign a maintenance staff member.`,
            type: "Alert"
        });

        res.status(201).json({ success: true, message: "Issue reported successfully! The Admin will review it soon." });

    } catch (error) {
        console.error("Report Alert Error:", error);
        res.status(500).json({ success: false, message: error.message });
    }
};

exports.getResidentAlertsHistory = async (req, res) => {
    try {
        const userId = req.params.userId;
        const alerts = await ResidentModel.getResidentAlerts(userId);
        res.json({ success: true, data: alerts });
    } catch (error) {
        console.error("Fetch Alerts Error:", error);
        res.status(500).json({ success: false, message: error.message });
    }
};

exports.searchResidents = async (req, res) => {
    const searchQuery = req.query.q || ''; 
    try {
        const users = await ResidentModel.searchByName(searchQuery);
        res.json(users);
    } catch (error) {
        console.error("Error searching residents:", error);
        res.status(500).json({ error: error.message });
    }
};