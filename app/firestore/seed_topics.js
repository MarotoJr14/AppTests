// seed_topics.js
// Run once with: node seed_topics.js
// Requires: npm install firebase-admin
// Place your Firebase service account JSON as serviceAccount.json

const admin = require('firebase-admin');
const serviceAccount = require('./blue-sailing-test-firebase-adminsdk-fbsvc-dadd2dc472.json');

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

// ── No sample questions included in this topic seed file ─────────────────

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

  console.log('\nDone!');
  process.exit(0);
}

seed().catch((e) => { console.error(e); process.exit(1); });
