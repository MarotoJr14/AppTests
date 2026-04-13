import 'package:cloud_firestore/cloud_firestore.dart';

class Topic {
  final String id;
  final String name;
  final int order;
  final int examQuestionCount;
  final String imageUrl;

  const Topic({
    required this.id,
    required this.name,
    required this.order,
    required this.examQuestionCount,
    required this.imageUrl,
  });

  factory Topic.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Topic(
      id: doc.id,
      name: d['name'] as String,
      order: d['order'] as int,
      examQuestionCount: d['examQuestionCount'] as int,
      imageUrl: d['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'order': order,
    'examQuestionCount': examQuestionCount,
    'imageUrl': imageUrl,
  };

  // Static catalogue — used for seeding and reference
  static const List<Map<String, dynamic>> catalogue = [
    {'id': 'nomenclatura_nautica',   'name': 'Nomenclatura náutica',          'order': 1,  'examQuestionCount': 4,  'imageUrl': ''},
    {'id': 'amarre_fondeo',          'name': 'Elementos de amarre y fondeo',  'order': 2,  'examQuestionCount': 2,  'imageUrl': ''},
    {'id': 'seguridad_mar',          'name': 'Seguridad en la mar',           'order': 3,  'examQuestionCount': 4,  'imageUrl': ''},
    {'id': 'legislacion',            'name': 'Legislación',                   'order': 4,  'examQuestionCount': 2,  'imageUrl': ''},
    {'id': 'balizamiento',           'name': 'Balizamiento',                  'order': 5,  'examQuestionCount': 5,  'imageUrl': ''},
    {'id': 'reglamento_abordajes',   'name': 'Reglamento de abordajes',       'order': 6,  'examQuestionCount': 10, 'imageUrl': ''},
    {'id': 'maniobra_navegacion',    'name': 'Maniobra y navegación',         'order': 7,  'examQuestionCount': 2,  'imageUrl': ''},
    {'id': 'emergencias_mar',        'name': 'Emergencias en la mar',         'order': 8,  'examQuestionCount': 3,  'imageUrl': ''},
    {'id': 'meteorologia',           'name': 'Meteorología',                  'order': 9,  'examQuestionCount': 4,  'imageUrl': ''},
    {'id': 'teoria_navegacion',      'name': 'Teoría de la navegación',       'order': 10, 'examQuestionCount': 5,  'imageUrl': ''},
    {'id': 'carta_navegacion',       'name': 'Carta de navegación',           'order': 11, 'examQuestionCount': 4,  'imageUrl': ''},
  ];
}
