# Blue Sailing Tests

App de preparación para el examen de **Patrón de Recreo**, desarrollada en Flutter con Firebase como backend.

---

## Stack

| Capa | Tecnología |
|---|---|
| Frontend | Flutter (Android, iOS, Windows, macOS) |
| Auth | Firebase Authentication (email/contraseña) |
| Base de datos | Cloud Firestore |
| Backend logic | Dart (servicios cliente) |

---

## Estructura del proyecto

```
lib/
  main.dart                    ← Punto de entrada + AuthGate
  theme/
    app_theme.dart             ← Colores, tipografía, ThemeData
  models/
    topic.dart                 ← Modelo Topic + catálogo estático
    question.dart              ← Modelo Question + Answer
    exam.dart                  ← Modelo Exam, ExamSection, ExamQuestionEntry
    user_topic_stats.dart      ← Modelo UserTopicStats
  services/
    auth_service.dart          ← Login, reset de contraseña, perfil
    question_service.dart      ← Consultas al banco de preguntas
    exam_service.dart          ← Crear, completar y consultar exámenes
    stats_service.dart         ← Estadísticas por tema
  screens/
    auth/
      login_screen.dart
      forgot_password_screen.dart
    home/
      home_screen.dart
    topic/
      topic_list_screen.dart
    question/
      practice_battery_screen.dart   ← Batería libre (tema o aleatoria)
      random_battery_screen.dart
      review_screen.dart
    exam/
      exam_name_screen.dart          ← Paso 1: nombre del examen
      exam_battery_screen.dart       ← Examen real 45 preguntas
      exam_review_screen.dart        ← Revisión post-examen
    stats/
      stats_screen.dart
      exam_history_screen.dart
      topic_stats_screen.dart
  widgets/
    question_card.dart         ← Card reutilizable (modo práctica y revisión)
    battery_nav_bar.dart       ← Barra ANTERIOR / TERMINAR / SIGUIENTE
firestore/
  firestore.rules              ← Reglas de seguridad
  firestore.indexes.json       ← Índices compuestos
  seed_firestore.js            ← Script para poblar la base de datos
```

---

## Configuración inicial

### 1. Crear proyecto Firebase

1. Ve a [console.firebase.google.com](https://console.firebase.google.com)
2. Crea un nuevo proyecto
3. Activa **Authentication → Email/contraseña**
4. Activa **Cloud Firestore** (modo producción)

### 2. Conectar Flutter con Firebase

```bash
# Instala FlutterFire CLI
dart pub global activate flutterfire_cli

# Desde la raíz del proyecto
flutterfire configure
```

Esto genera automáticamente `lib/firebase_options.dart`.

Luego descomenta en `main.dart`:
```dart
import 'firebase_options.dart';
// ...
await Firebase.initializeApp(
options: DefaultFirebaseOptions.currentPlatform,
);
```

### 3. Desplegar reglas e índices Firestore

```bash
# Instala Firebase CLI si no lo tienes
npm install -g firebase-tools
firebase login

# Desde la raíz del proyecto
firebase deploy --only firestore:rules --project blue-sailing-test-8a843
firebase deploy --only firestore:indexes --project blue-sailing-test-8a843
```

### 4. Poblar la base de datos (seed)

```bash
cd firestore
npm install firebase-admin

# Descarga tu service account desde Firebase Console →
# Configuración del proyecto → Cuentas de servicio → Generar clave
# Guárdala como firestore/blue-sailing-test-8a843-firebase-adminsdk-fbsvc-bdc46616f3.json

node seed_topics.js
node seed_questions.js
node seed_codes.js
```

Los scripts escriben los temas, preguntas y códigos de registro en el proyecto `blue-sailing-test-8a843`.
**Añade tu banco completo de preguntas** directamente en `seed_questions.js`, respetando la estructura existente.

### 5. Ejecutar la app

```bash
flutter pub get
flutter run
```

---

## Estructura de colecciones Firestore

### `topics/{topicId}`
```json
{
  "name": "Nomenclatura náutica",
  "order": 1,
  "examQuestionCount": 4,
  "imageUrl": ""
}
```

### `questions/{questionId}`
```json
{
  "topicId": "nomenclatura_nautica",
  "topicName": "Nomenclatura náutica",
  "statement": "¿Cómo se denomina la parte delantera de una embarcación?",
  "answers": [
    { "id": "a", "text": "Popa" },
    { "id": "b", "text": "Proa" },
    { "id": "c", "text": "Babor" },
    { "id": "d", "text": "Estribor" }
  ],
  "correctAnswerId": "b",
  "createdAt": "timestamp"
}
```

### `exams/{examId}`
```json
{
  "userId": "...",
  "name": "Convocatoria junio 2025",
  "createdAt": "timestamp",
  "completedAt": "timestamp | null",
  "totalQuestions": 45,
  "correctCount": 38,
  "status": "completed",
  "sections": [ /* array de 11 secciones con preguntas embebidas */ ]
}
```

### `userTopicStats/{userId}_{topicId}`
```json
{
  "userId": "...",
  "topicId": "nomenclatura_nautica",
  "topicName": "Nomenclatura náutica",
  "totalAnswered": 20,
  "totalCorrect": 17
}
```

---

## Añadir preguntas al banco

Edita `firestore/seed_firestore.js` y añade objetos al array `sampleQuestions`:

```js
{
  topicId: 'reglamento_abordajes',       // ID del tema
  topicName: 'Reglamento de abordajes',  // Nombre legible
  statement: 'Enunciado de la pregunta...',
  answers: [
    { id: 'a', text: 'Respuesta A' },
    { id: 'b', text: 'Respuesta B' },
    { id: 'c', text: 'Respuesta C' },
    { id: 'd', text: 'Respuesta D' },
  ],
  correctAnswerId: 'b',  // ID de la respuesta correcta
}
```

El examen real requiere **mínimo** estas preguntas por tema:

| Tema | Mínimo |
|---|---|
| Nomenclatura náutica | 4 |
| Elementos de amarre y fondeo | 2 |
| Seguridad en la mar | 4 |
| Legislación | 2 |
| Balizamiento | 5 |
| Reglamento de abordajes | 10 |
| Maniobra y navegación | 2 |
| Emergencias en la mar | 3 |
| Meteorología | 4 |
| Teoría de la navegación | 5 |
| Carta de navegación | 4 |
| **Total** | **45** |
