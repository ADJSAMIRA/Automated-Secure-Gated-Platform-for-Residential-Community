import 'package:flutter/material.dart';

class ManageEventsPage extends StatelessWidget {
  final Function(int) onOptionSelected; 
  final VoidCallback onBack;     

  const ManageEventsPage({
    super.key, 
    required this.onOptionSelected, 
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
   
    return Container(
      color: const Color(0xFFF8F9FD),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4), 
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF1B2559), size: 20),
                    onPressed: onBack, 
                  ),
                ),
                const SizedBox(width: 8),
                
              
                Padding(
                  padding: const EdgeInsets.only(top: 6), 
                  child: Container(
                    width: 5, 
                    height: 25, 
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A237E), 
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Event Management", 
                        style: TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold, 
                          color: Color(0xFF1B2559),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Control community activities, scheduling, and declarations.",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

           
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.85, 
                children: [
                  _buildModernCard(context, "Approve Event", "New Event of resident", Icons.fact_check_outlined, Colors.green, 201),
                  _buildModernCard(context, "Create Event", "New Event", Icons.add_circle_outline, Colors.blue, 202),
                  _buildModernCard(context, "Edit Event", "Modify info event", Icons.edit_note_outlined, const Color(0xFF673AB7), 203),
                  _buildModernCard(context, "Delete Event", "Remove Event from list events", Icons.delete_sweep_outlined, Colors.red, 204),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

 
  Widget _buildModernCard(BuildContext context, String title, String subtitle, IconData icon, Color color, int targetIndex) {
    return InkWell(
      onTap: () => onOptionSelected(targetIndex), // عند الضغط ينتقل للـ index الخاص بالصفحة المطلوبة
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015), 
              blurRadius: 15, 
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const Spacer(),
            Text(
              title, 
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF1B2559)),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle, 
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
            const Spacer(),
            Divider(color: Colors.grey.shade100, height: 20, thickness: 0.5),
            Row(
              children: [
                Text("Manage", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                const Spacer(),
                Icon(Icons.chevron_right_rounded, size: 16, color: color),
              ],
            ),
          ],
        ),
      ),
    );
  }
}