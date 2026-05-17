const ChatModel = require('../models/chatModel');
const NotificationModel = require('../models/notificationModel'); 

exports.sendMessage = async (req, res) => {
    const { sender_id, receiver_id, content } = req.body;
    try {
        const convId = await ChatModel.getOrCreateConversation(sender_id, receiver_id);
        
        await ChatModel.saveMessage(convId, sender_id, receiver_id, content);
        
        const senderName = await ChatModel.getSenderName(sender_id);

        await NotificationModel.create({
            user_id: receiver_id, 
            title: `New Message from ${senderName}`,
            message: content.length > 50 ? `${content.substring(0, 50)}...` : content, 
        });

        res.json({ success: true, id_conversation: convId });
    } catch (error) {
        console.error("SQL Error:", error.message);
        res.status(500).json({ success: false, message: "Error saving message" });
    }
};

exports.getChatHistory = async (req, res) => {
    const { user1, user2 } = req.params; 
    try {
        const convId = await ChatModel.getOrCreateConversation(user1, user2);
        await ChatModel.markAsRead(convId, user2);
        const messages = await ChatModel.getMessages(convId);
        res.json(messages);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.getUserInbox = async (req, res) => {
    const { userId } = req.params;
    try {
        const inbox = await ChatModel.getUserInbox(userId);
        res.json(inbox); 
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.deleteMessage = async (req, res) => {
    const { messageId } = req.params;
    try {
        const result = await ChatModel.deleteMessageById(messageId);
        if (result.affectedRows > 0) {
            res.json({ success: true, message: "Message deleted successfully" });
        } else {
            res.status(404).json({ success: false, message: "Message not found" });
        }
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

exports.editMessage = async (req, res) => {
    const { messageId } = req.params;
    const { newContent } = req.body;
    if (!newContent || newContent.trim() === "") {
        return res.status(400).json({ success: false, message: "Content cannot be empty" });
    }
    try {
        const result = await ChatModel.updateMessageContent(messageId, newContent);
        if (result.affectedRows > 0) {
            res.json({ success: true, message: "Message updated successfully" });
        } else {
            res.status(404).json({ success: false, message: "Message not found" });
        }
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};