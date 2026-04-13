// seed_firestore.js
// Run once with: node seed_firestore.js
// Requires: npm install firebase-admin
// Place your Firebase service account JSON as serviceAccount.json

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccount.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// ── Topics ────────────────────────────────────────────────────────────────
const topics = [
  { id: 'nomenclatura_nautica',  name: 'Nomenclatura náutica',         order: 1,  examQuestionCount: 4,  imageUrl: '' },
  { id: 'amarre_fondeo',         name: 'Elementos de amarre y fondeo', order: 2,  examQuestionCount: 2,  imageUrl: '' },
  { id: 'seguridad_mar',         name: 'Seguridad en la mar',          order: 3,  examQuestionCount: 4,  imageUrl: '' },
  { id: 'legislacion',           name: 'Legislación',                  order: 4,  examQuestionCount: 2,  imageUrl: '' },
  { id: 'balizamiento',          name: 'Balizamiento',                 order: 5,  examQuestionCount: 5,  imageUrl: '' },
  { id: 'reglamento_abordajes',  name: 'Reglamento de abordajes',      order: 6,  examQuestionCount: 10, imageUrl: '' },
  { id: 'maniobra_navegacion',   name: 'Maniobra y navegación',        order: 7,  examQuestionCount: 2,  imageUrl: '' },
  { id: 'emergencias_mar',       name: 'Emergencias en la mar',        order: 8,  examQuestionCount: 3,  imageUrl: '' },
  { id: 'meteorologia',          name: 'Meteorología',                 order: 9,  examQuestionCount: 4,  imageUrl: '' },
  { id: 'teoria_navegacion',     name: 'Teoría de la navegación',      order: 10, examQuestionCount: 5,  imageUrl: '' },
  { id: 'carta_navegacion',      name: 'Carta de navegación',          order: 11, examQuestionCount: 4,  imageUrl: '' },
];

// ── Sample questions (add your full bank here) ────────────────────────────
// Structure: { topicId, topicName, statement, answers:[{id,text}], correctAnswerId }
const sampleQuestions = [
  {
    topicId: 'nomenclatura_nautica',
    topicName: 'Nomenclatura náutica',
    statement: '¿Cómo se denomina la parte delantera de una embarcación?',
    answers: [
      { id: 'a', text: 'Popa' },
      { id: 'b', text: 'Proa' },
      { id: 'c', text: 'Babor' },
      { id: 'd', text: 'Estribor' },
    ],
    correctAnswerId: 'b',
  },
  {
    topicId: 'nomenclatura_nautica',
    topicName: 'Nomenclatura náutica',
    statement: '¿Cuál es el lado izquierdo de una embarcación mirando hacia proa?',
    answers: [
      { id: 'a', text: 'Estribor' },
      { id: 'b', text: 'Popa' },
      { id: 'c', text: 'Babor' },
      { id: 'd', text: 'Amura' },
    ],
    correctAnswerId: 'c',
  },
  {
    topicId: 'nomenclatura_nautica',
    topicName: 'Nomenclatura náutica',
    statement: '¿Cómo se llama la distancia vertical entre la línea de flotación y la cubierta principal?',
    answers: [
      { id: 'a', text: 'Calado' },
      { id: 'b', text: 'Manga' },
      { id: 'c', text: 'Franco bordo' },
      { id: 'd', text: 'Eslora' },
    ],
    correctAnswerId: 'c',
  },
  {
    topicId: 'nomenclatura_nautica',
    topicName: 'Nomenclatura náutica',
    statement: '¿Qué es la eslora de una embarcación?',
    answers: [
      { id: 'a', text: 'La anchura máxima del casco' },
      { id: 'b', text: 'La profundidad de la quilla bajo el agua' },
      { id: 'c', text: 'La longitud total de la embarcación' },
      { id: 'd', text: 'El peso total en vacío' },
    ],
    correctAnswerId: 'c',
  },
  {
    topicId: 'amarre_fondeo',
    topicName: 'Elementos de amarre y fondeo',
    statement: '¿Cuál de los siguientes es un tipo de nudo de amarre?',
    answers: [
      { id: 'a', text: 'Nudo de ballestrinque' },
      { id: 'b', text: 'Nudo alpino' },
      { id: 'c', text: 'Nudo prusik' },
      { id: 'd', text: 'Nudo de guía' },
    ],
    correctAnswerId: 'a',
  },
  {
    topicId: 'amarre_fondeo',
    topicName: 'Elementos de amarre y fondeo',
    statement: '¿Qué es una espía?',
    answers: [
      { id: 'a', text: 'Un tipo de ancla' },
      { id: 'b', text: 'Un cabo que se lleva a tierra o a otro punto de amarre' },
      { id: 'c', text: 'Un dispositivo de fondeo' },
      { id: 'd', text: 'Una línea de remolque' },
    ],
    correctAnswerId: 'b',
  },
  {
    topicId: 'seguridad_mar',
    topicName: 'Seguridad en la mar',
    statement: '¿Cuál es la señal de auxilio internacional más reconocida?',
    answers: [
      { id: 'a', text: 'Tres destellos cortos de linterna' },
      { id: 'b', text: 'SOS emitido en morse por cualquier medio' },
      { id: 'c', text: 'Dos cohetes paracaídas disparados con 30 segundos de diferencia' },
      { id: 'd', text: 'Una bandera naranja con un círculo negro' },
    ],
    correctAnswerId: 'b',
  },
  {
    topicId: 'seguridad_mar',
    topicName: 'Seguridad en la mar',
    statement: '¿Qué color tienen los chalecos salvavidas reglamentarios?',
    answers: [
      { id: 'a', text: 'Rojo' },
      { id: 'b', text: 'Azul' },
      { id: 'c', text: 'Amarillo o naranja' },
      { id: 'd', text: 'Blanco' },
    ],
    correctAnswerId: 'c',
  },
  {
    topicId: 'meteorologia',
    topicName: 'Meteorología',
    statement: '¿Qué indica una bajada rápida del barómetro?',
    answers: [
      { id: 'a', text: 'Mejora del tiempo' },
      { id: 'b', text: 'Tiempo estable' },
      { id: 'c', text: 'Aproximación de mal tiempo' },
      { id: 'd', text: 'Niebla espesa' },
    ],
    correctAnswerId: 'c',
  },
  {
    topicId: 'reglamento_abordajes',
    topicName: 'Reglamento de abordajes',
    statement: 'Dos buques de propulsión mecánica se aproximan en rumbos opuestos. ¿Qué deben hacer?',
    answers: [
      { id: 'a', text: 'El buque de mayor eslora cede el paso' },
      { id: 'b', text: 'Ambos caen a estribor' },
      { id: 'c', text: 'Ambos caen a babor' },
      { id: 'd', text: 'El más rápido cede el paso' },
    ],
    correctAnswerId: 'b',
  },
];

// ── Seed function ─────────────────────────────────────────────────────────
async function seed() {
  console.log('Seeding topics...');
  const topicBatch = db.batch();
  for (const t of topics) {
    const { id, ...data } = t;
    topicBatch.set(db.collection('topics').doc(id), data);
  }
  await topicBatch.commit();
  console.log(`✓ ${topics.length} topics written`);

  console.log('Seeding sample questions...');
  const qBatch = db.batch();
  for (const q of sampleQuestions) {
    const ref = db.collection('questions').doc();
    qBatch.set(ref, { ...q, createdAt: admin.firestore.FieldValue.serverTimestamp() });
  }
  await qBatch.commit();
  console.log(`✓ ${sampleQuestions.length} sample questions written`);

  console.log('\nDone! Add more questions following the same structure.');
  process.exit(0);
}

seed().catch((e) => { console.error(e); process.exit(1); });
