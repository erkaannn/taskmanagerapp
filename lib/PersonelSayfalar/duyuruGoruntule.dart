import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DuyuruGoruntule extends StatefulWidget {
  const DuyuruGoruntule({super.key});

  @override
  State<DuyuruGoruntule> createState() => _DuyuruGoruntuleState();
}

class _DuyuruGoruntuleState extends State<DuyuruGoruntule> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Duyurular',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo[600],
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo[600]!.withOpacity(0.1),
              Colors.grey[100]!,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header kısmı
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.indigo[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_active,
                      color: Colors.indigo[600],
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Güncel Duyurular',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'En son duyuruları burada görüntüleyebilirsiniz',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Duyuru listesi
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Duyurular')
                      .orderBy("id", descending: true)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Duyurular yükleniyor...',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Bir hata oluştu',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Duyurular yüklenirken bir sorun yaşandı',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_off_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Henüz duyuru bulunmuyor',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Yeni duyurular eklendiğinde burada görünecek',
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final documents = snapshot.data!.docs;

                    return RefreshIndicator(
                      onRefresh: () async {
                        setState(() {});
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          final doc = documents[index];
                          final data = doc.data() as Map<String, dynamic>;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Card(
                              elevation: 3,
                              shadowColor: Colors.black.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  _showDuyuruDetay(context, data);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.indigo[50],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.campaign,
                                              color: Colors.indigo[600],
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              data['duyuruBaslik'] ?? 'Başlık Yok',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        data['duyuruIcerik'] ?? 'İçerik Yok',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                          height: 1.4,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          if (data['tarih'] != null)
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  size: 16,
                                                  color: Colors.grey[500],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _formatDate(data['tarih']),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[500],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green[50],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Aktif',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.green[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDuyuruDetay(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.indigo[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.campaign,
                              color: Colors.indigo[600],
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Duyuru Detayı',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        data['duyuruBaslik'] ?? 'Başlık Yok',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (data['tarih'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatDate(data['tarih']),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Text(
                          data['duyuruIcerik'] ?? 'İçerik Yok',
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    try {
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();
        final now = DateTime.now();
        final difference = now.difference(date);
        
        if (difference.inDays == 0) {
          return 'Bugün ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
        } else if (difference.inDays == 1) {
          return 'Dün ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
        } else if (difference.inDays < 7) {
          return '${difference.inDays} gün önce';
        } else {
          return '${date.day}.${date.month}.${date.year}';
        }
      } else if (timestamp is String) {
        return timestamp;
      }
      return 'Tarih belirtilmemiş';
    } catch (e) {
      return 'Tarih belirtilmemiş';
    }
  }
}