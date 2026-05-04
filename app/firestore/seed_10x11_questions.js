// seed_10x11_questions.js
// Run once with: node seed_10x11_questions.js
// Requires: npm install firebase-admin
// Place your Firebase service account JSON as serviceAccount.json (same folder)

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccount.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const VALIDATE_ONLY = process.argv.includes('--validate-only');

// ── Topics ────────────────────────────────────────────────────────────────
const topics = [
  { id: 'nomenclatura_nautica', name: 'Nomenclatura náutica', order: 1, examQuestionCount: 4, imageUrl: '' },
  { id: 'amarre_fondeo', name: 'Elementos de amarre y fondeo', order: 2, examQuestionCount: 2, imageUrl: '' },
  { id: 'seguridad_mar', name: 'Seguridad en la mar', order: 3, examQuestionCount: 4, imageUrl: '' },
  { id: 'legislacion', name: 'Legislación', order: 4, examQuestionCount: 2, imageUrl: '' },
  { id: 'balizamiento', name: 'Balizamiento', order: 5, examQuestionCount: 5, imageUrl: '' },
  { id: 'reglamento_abordajes', name: 'Reglamento de abordajes', order: 6, examQuestionCount: 10, imageUrl: '' },
  { id: 'maniobra_navegacion', name: 'Maniobra y navegación', order: 7, examQuestionCount: 2, imageUrl: '' },
  { id: 'emergencias_mar', name: 'Emergencias en la mar', order: 8, examQuestionCount: 3, imageUrl: '' },
  { id: 'meteorologia', name: 'Meteorología', order: 9, examQuestionCount: 4, imageUrl: '' },
  { id: 'teoria_navegacion', name: 'Teoría de la navegación', order: 10, examQuestionCount: 5, imageUrl: '' },
  { id: 'carta_navegacion', name: 'Carta de navegación', order: 11, examQuestionCount: 4, imageUrl: '' },
];

const topicNameById = new Map(topics.map((t) => [t.id, t.name]));

function q(topicId, statement, answers, correctAnswerId) {
  const topicName = topicNameById.get(topicId);
  if (!topicName) throw new Error(`Unknown topicId: ${topicId}`);
  return { topicId, topicName, statement, answers, correctAnswerId };
}

// ── Questions (10 per topic, 11 topics = 110) ─────────────────────────────
// Structure: { topicId, topicName, statement, answers:[{id,text}], correctAnswerId }
const questions = [
  // 1) Nomenclatura náutica (10)
  q(
    'nomenclatura_nautica',
    '¿Cómo se denomina la parte delantera de una embarcación?',
    [
      { id: 'a', text: 'Popa' },
      { id: 'b', text: 'Proa' },
      { id: 'c', text: 'Babor' },
      { id: 'd', text: 'Estribor' },
    ],
    'b',
  ),
  q(
    'nomenclatura_nautica',
    '¿Cuál es el costado izquierdo de una embarcación mirando hacia proa?',
    [
      { id: 'a', text: 'Estribor' },
      { id: 'b', text: 'Popa' },
      { id: 'c', text: 'Babor' },
      { id: 'd', text: 'Amura' },
    ],
    'c',
  ),
  q(
    'nomenclatura_nautica',
    '¿Qué es la eslora de una embarcación?',
    [
      { id: 'a', text: 'La altura desde quilla a cubierta' },
      { id: 'b', text: 'La anchura máxima del casco' },
      { id: 'c', text: 'La longitud total de la embarcación' },
      { id: 'd', text: 'La distancia entre ruedas del timón' },
    ],
    'c',
  ),
  q(
    'nomenclatura_nautica',
    '¿Qué es la manga de una embarcación?',
    [
      { id: 'a', text: 'La anchura máxima del casco' },
      { id: 'b', text: 'La longitud total' },
      { id: 'c', text: 'La parte sumergida del casco' },
      { id: 'd', text: 'La altura del mástil' },
    ],
    'a',
  ),
  q(
    'nomenclatura_nautica',
    '¿Cómo se llama la parte sumergida del casco?',
    [
      { id: 'a', text: 'Obra muerta' },
      { id: 'b', text: 'Obra viva' },
      { id: 'c', text: 'Cubierta' },
      { id: 'd', text: 'Regala' },
    ],
    'b',
  ),
  q(
    'nomenclatura_nautica',
    '¿Qué es el calado?',
    [
      { id: 'a', text: 'La distancia vertical entre flotación y quilla' },
      { id: 'b', text: 'La longitud entre perpendiculares' },
      { id: 'c', text: 'La anchura en la línea de flotación' },
      { id: 'd', text: 'La altura libre bajo el puente' },
    ],
    'a',
  ),
  q(
    'nomenclatura_nautica',
    '¿Qué es el francobordo?',
    [
      { id: 'a', text: 'La parte de popa más alta' },
      { id: 'b', text: 'La distancia vertical entre flotación y cubierta' },
      { id: 'c', text: 'La parte sumergida del casco' },
      { id: 'd', text: 'El ángulo de escora' },
    ],
    'b',
  ),
  q(
    'nomenclatura_nautica',
    '¿Cómo se denominan las partes laterales de la embarcación hacia la proa?',
    [
      { id: 'a', text: 'Aletas' },
      { id: 'b', text: 'Amuras' },
      { id: 'c', text: 'Cuadernas' },
      { id: 'd', text: 'Regalas' },
    ],
    'b',
  ),
  q(
    'nomenclatura_nautica',
    '¿Cómo se denominan las partes laterales de la embarcación hacia la popa?',
    [
      { id: 'a', text: 'Aletas' },
      { id: 'b', text: 'Amuras' },
      { id: 'c', text: 'Proas' },
      { id: 'd', text: 'Rodas' },
    ],
    'a',
  ),
  q(
    'nomenclatura_nautica',
    '¿Qué pieza longitudinal suele ser la “columna vertebral” del casco en la parte inferior?',
    [
      { id: 'a', text: 'Roda' },
      { id: 'b', text: 'Botalón' },
      { id: 'c', text: 'Quilla' },
      { id: 'd', text: 'Codaste' },
    ],
    'c',
  ),

  // 2) Elementos de amarre y fondeo (10)
  q(
    'amarre_fondeo',
    '¿Qué elemento de la embarcación se utiliza para dar vueltas al cabo en el amarre?',
    [
      { id: 'a', text: 'Cornamusa' },
      { id: 'b', text: 'Bitácora' },
      { id: 'c', text: 'Sentina' },
      { id: 'd', text: 'Relinga' },
    ],
    'a',
  ),
  q(
    'amarre_fondeo',
    '¿Qué es una “espía” en maniobras de amarre?',
    [
      { id: 'a', text: 'Un tipo de ancla' },
      { id: 'b', text: 'Un cabo que se lleva a un punto distinto para ayudar a la maniobra' },
      { id: 'c', text: 'Una boya de fondeo' },
      { id: 'd', text: 'Una polea de la jarcia' },
    ],
    'b',
  ),
  q(
    'amarre_fondeo',
    '¿Cómo se llama el objeto fijo en el muelle al que se amarra un cabo (poste o “bolardo”)?',
    [
      { id: 'a', text: 'Noray' },
      { id: 'b', text: 'Escandallo' },
      { id: 'c', text: 'Compás' },
      { id: 'd', text: 'Orza' },
    ],
    'a',
  ),
  q(
    'amarre_fondeo',
    '¿Qué nudo es típico para amarrar un cabo a una barandilla o a un noray?',
    [
      { id: 'a', text: 'Ballestrinque' },
      { id: 'b', text: 'As de guía' },
      { id: 'c', text: 'Nudo de pescador' },
      { id: 'd', text: 'Nudo ocho' },
    ],
    'a',
  ),
  q(
    'amarre_fondeo',
    '¿Para qué sirve el “as de guía” (bowline)?',
    [
      { id: 'a', text: 'Para unir dos cabos de distinto grosor' },
      { id: 'b', text: 'Para hacer una gaza fija que no corre' },
      { id: 'c', text: 'Para acortar un cabo sin cortarlo' },
      { id: 'd', text: 'Para marcar el centro del cabo' },
    ],
    'b',
  ),
  q(
    'amarre_fondeo',
    '¿Qué se entiende por “borneo” cuando una embarcación está fondeada?',
    [
      { id: 'a', text: 'Reparación del ancla en cubierta' },
      { id: 'b', text: 'Giro alrededor del ancla por efecto de viento/corriente' },
      { id: 'c', text: 'Cambio de motor a vela' },
      { id: 'd', text: 'Aumento de velocidad para tensar el cabo' },
    ],
    'b',
  ),
  q(
    'amarre_fondeo',
    '¿Qué elemento aporta peso y ayuda a que el ancla trabaje mejor apoyada en el fondo?',
    [
      { id: 'a', text: 'La caña del timón' },
      { id: 'b', text: 'La cadena del ancla' },
      { id: 'c', text: 'El guardamancebo' },
      { id: 'd', text: 'La batería de servicio' },
    ],
    'b',
  ),
  q(
    'amarre_fondeo',
    '¿Qué es un “muerto” en fondeos?',
    [
      { id: 'a', text: 'Una boya con luz blanca' },
      { id: 'b', text: 'Un lastre fijo en el fondo al que se une una boya de amarre' },
      { id: 'c', text: 'Un tipo de ancla plegable' },
      { id: 'd', text: 'Un nudo para acortar cadena' },
    ],
    'b',
  ),
  q(
    'amarre_fondeo',
    '¿Qué se recomienda hacer antes de fondear para evitar garrear?',
    [
      { id: 'a', text: 'Fondear siempre con el motor parado' },
      { id: 'b', text: 'Comprobar fondo, sonda y dar el largo adecuado de cabo/cadena' },
      { id: 'c', text: 'Fondear lo más cerca posible de la costa' },
      { id: 'd', text: 'Sacar todo el cabo disponible' },
    ],
    'b',
  ),
  q(
    'amarre_fondeo',
    '¿Cómo se llama la acción de recoger el ancla y su cadena/cabo?',
    [
      { id: 'a', text: 'Virar' },
      { id: 'b', text: 'Arribar' },
      { id: 'c', text: 'Derivar' },
      { id: 'd', text: 'Escorar' },
    ],
    'a',
  ),

  // 3) Seguridad en la mar (10)
  q(
    'seguridad_mar',
    '¿Cuál es el canal internacional de socorro, urgencia y seguridad en VHF?',
    [
      { id: 'a', text: 'Canal 6' },
      { id: 'b', text: 'Canal 9' },
      { id: 'c', text: 'Canal 16' },
      { id: 'd', text: 'Canal 72' },
    ],
    'c',
  ),
  q(
    'seguridad_mar',
    '¿Qué significa la señal MAYDAY?',
    [
      { id: 'a', text: 'Seguridad: aviso a la navegación' },
      { id: 'b', text: 'Urgencia: situación seria sin peligro inmediato' },
      { id: 'c', text: 'Socorro: peligro grave e inminente' },
      { id: 'd', text: 'Prueba de radio' },
    ],
    'c',
  ),
  q(
    'seguridad_mar',
    '¿Qué color suele ser más visible y habitual en chalecos salvavidas homologados?',
    [
      { id: 'a', text: 'Negro' },
      { id: 'b', text: 'Blanco' },
      { id: 'c', text: 'Amarillo o naranja' },
      { id: 'd', text: 'Verde oscuro' },
    ],
    'c',
  ),
  q(
    'seguridad_mar',
    'Ante un incendio a bordo, ¿qué acción es PRIORITARIA si es seguro hacerlo?',
    [
      { id: 'a', text: 'Echar gasolina para “ahogar” el fuego' },
      { id: 'b', text: 'Cortar el suministro de combustible y la ventilación del compartimento' },
      { id: 'c', text: 'Abrir todas las escotillas para ventilar' },
      { id: 'd', text: 'Aumentar velocidad para crear viento aparente' },
    ],
    'b',
  ),
  q(
    'seguridad_mar',
    '¿Qué equipo ayuda a localizar a una persona en el agua durante la noche?',
    [
      { id: 'a', text: 'Una luz estroboscópica/flash del chaleco' },
      { id: 'b', text: 'Un sextante' },
      { id: 'c', text: 'Un anemómetro' },
      { id: 'd', text: 'Una driza' },
    ],
    'a',
  ),
  q(
    'seguridad_mar',
    '¿Cuál es una medida eficaz para prevenir la hipotermia tras caer al agua?',
    [
      { id: 'a', text: 'Nadar fuerte para entrar en calor' },
      { id: 'b', text: 'Adoptar posición fetal (HELP) y minimizar movimientos' },
      { id: 'c', text: 'Quitarse el chaleco para moverse mejor' },
      { id: 'd', text: 'Beber agua de mar para hidratarse' },
    ],
    'b',
  ),
  q(
    'seguridad_mar',
    '¿Qué elemento es recomendable llevar en cubierta para maniobras con mal tiempo?',
    [
      { id: 'a', text: 'Arnés y línea de vida' },
      { id: 'b', text: 'Cámara de fotos' },
      { id: 'c', text: 'Sombrilla' },
      { id: 'd', text: 'Radio AM' },
    ],
    'a',
  ),
  q(
    'seguridad_mar',
    '¿Qué debe hacerse con una bengala antes de usarla?',
    [
      { id: 'a', text: 'Probarla dentro de la cabina' },
      { id: 'b', text: 'Comprobar caducidad y leer instrucciones' },
      { id: 'c', text: 'Sumergirla en agua dulce' },
      { id: 'd', text: 'Pintarla de color rojo' },
    ],
    'b',
  ),
  q(
    'seguridad_mar',
    '¿Qué es una balsa salvavidas?',
    [
      { id: 'a', text: 'Un flotador circular' },
      { id: 'b', text: 'Un elemento para medir profundidad' },
      { id: 'c', text: 'Un equipo de abandono para mantenerse a flote protegidos' },
      { id: 'd', text: 'Un tipo de ancla' },
    ],
    'c',
  ),
  q(
    'seguridad_mar',
    'En caso de “hombre al agua”, ¿qué acción inicial ayuda a no perderlo de vista?',
    [
      { id: 'a', text: 'Mirar el GPS y seguir navegando' },
      { id: 'b', text: 'Asignar un vigía fijo apuntando a la persona' },
      { id: 'c', text: 'Apagar todas las luces' },
      { id: 'd', text: 'Cambiar de rumbo al azar' },
    ],
    'b',
  ),

  // 4) Legislación (10)
  q(
    'legislacion',
    '¿Qué documento recoge las normas de seguridad y convivencia a bordo (si se establece por el armador/patrón)?',
    [
      { id: 'a', text: 'Cuaderno de bitácora' },
      { id: 'b', text: 'Reglamento interior' },
      { id: 'c', text: 'Carta náutica' },
      { id: 'd', text: 'Parte meteorológico' },
    ],
    'b',
  ),
  q(
    'legislacion',
    '¿Qué autoridad suele ser competente en materia de inspección y control marítimo en España?',
    [
      { id: 'a', text: 'Capitanía Marítima' },
      { id: 'b', text: 'Dirección General de Tráfico' },
      { id: 'c', text: 'Ayuntamiento' },
      { id: 'd', text: 'Colegio de ingenieros' },
    ],
    'a',
  ),
  q(
    'legislacion',
    '¿Cuál es la finalidad principal del seguro de responsabilidad civil de la embarcación?',
    [
      { id: 'a', text: 'Cubrir gastos de combustible' },
      { id: 'b', text: 'Cubrir daños a terceros' },
      { id: 'c', text: 'Cubrir el precio de compra del barco' },
      { id: 'd', text: 'Cubrir el alquiler del amarre' },
    ],
    'b',
  ),
  q(
    'legislacion',
    '¿Qué se entiende por “patrón” de una embarcación de recreo?',
    [
      { id: 'a', text: 'La persona que limpia la cubierta' },
      { id: 'b', text: 'Quien ejerce el mando y la responsabilidad de la navegación' },
      { id: 'c', text: 'El propietario siempre, sin excepción' },
      { id: 'd', text: 'El pasajero con más experiencia' },
    ],
    'b',
  ),
  q(
    'legislacion',
    '¿Qué es el “armador” de una embarcación?',
    [
      { id: 'a', text: 'Quien equipa y pone en servicio la embarcación' },
      { id: 'b', text: 'El fabricante del motor' },
      { id: 'c', text: 'El capitán de puerto' },
      { id: 'd', text: 'El operador de radio' },
    ],
    'a',
  ),
  q(
    'legislacion',
    '¿Cuál es una obligación general al navegar en zonas con tráfico intenso?',
    [
      { id: 'a', text: 'Navegar sin luces para no deslumbrar' },
      { id: 'b', text: 'Mantener una vigilancia eficaz en todo momento' },
      { id: 'c', text: 'Usar siempre el piloto automático' },
      { id: 'd', text: 'No escuchar la radio VHF' },
    ],
    'b',
  ),
  q(
    'legislacion',
    'En general, ¿quién es responsable de que el material de seguridad esté a bordo y en condiciones?',
    [
      { id: 'a', text: 'El astillero' },
      { id: 'b', text: 'El patrón/armador, según el caso' },
      { id: 'c', text: 'El primer pasajero' },
      { id: 'd', text: 'El socorrista de la playa' },
    ],
    'b',
  ),
  q(
    'legislacion',
    '¿Qué se recomienda llevar a bordo para poder identificar la embarcación en inspecciones?',
    [
      { id: 'a', text: 'Factura del supermercado' },
      { id: 'b', text: 'Documentación de la embarcación y del patrón (titulación, seguro, etc.)' },
      { id: 'c', text: 'Manual de cocina' },
      { id: 'd', text: 'Guía turística' },
    ],
    'b',
  ),
  q(
    'legislacion',
    '¿Qué indica la “lista” (6ª, 7ª, etc.) en una embarcación en España, de forma general?',
    [
      { id: 'a', text: 'El tipo de pintura del casco' },
      { id: 'b', text: 'La clase/uso administrativo de la embarcación' },
      { id: 'c', text: 'La potencia del motor' },
      { id: 'd', text: 'La altura del mástil' },
    ],
    'b',
  ),
  q(
    'legislacion',
    '¿Qué se entiende por “zona de navegación” en embarcaciones de recreo?',
    [
      { id: 'a', text: 'La zona del barco donde está el timón' },
      { id: 'b', text: 'El límite de navegación autorizado según categoría/equipamiento' },
      { id: 'c', text: 'La zona de fondeo de un puerto' },
      { id: 'd', text: 'El área donde se permite pescar' },
    ],
    'b',
  ),

  // 5) Balizamiento (10)
  q(
    'balizamiento',
    'En el sistema IALA Región A (España), entrando a puerto, ¿qué color corresponde a la marca lateral de babor?',
    [
      { id: 'a', text: 'Verde' },
      { id: 'b', text: 'Rojo' },
      { id: 'c', text: 'Amarillo' },
      { id: 'd', text: 'Blanco' },
    ],
    'b',
  ),
  q(
    'balizamiento',
    'En IALA Región A, entrando a puerto, ¿qué color corresponde a la marca lateral de estribor?',
    [
      { id: 'a', text: 'Rojo' },
      { id: 'b', text: 'Verde' },
      { id: 'c', text: 'Negro' },
      { id: 'd', text: 'Azul' },
    ],
    'b',
  ),
  q(
    'balizamiento',
    '¿Qué marca indica “aguas seguras” (safe water mark) en general?',
    [
      { id: 'a', text: 'Amarilla con cruz' },
      { id: 'b', text: 'Franjas verticales rojas y blancas' },
      { id: 'c', text: 'Negra y amarilla con dos conos' },
      { id: 'd', text: 'Roja con cilindro' },
    ],
    'b',
  ),
  q(
    'balizamiento',
    '¿Qué marca indica “peligro aislado” (isolated danger mark)?',
    [
      { id: 'a', text: 'Negra con una banda roja y dos esferas negras como marca de tope' },
      { id: 'b', text: 'Verde con cono hacia arriba' },
      { id: 'c', text: 'Roja con luz blanca' },
      { id: 'd', text: 'Blanca con banda azul' },
    ],
    'a',
  ),
  q(
    'balizamiento',
    '¿Qué color caracteriza a las marcas especiales (special mark)?',
    [
      { id: 'a', text: 'Rojo' },
      { id: 'b', text: 'Verde' },
      { id: 'c', text: 'Amarillo' },
      { id: 'd', text: 'Negro' },
    ],
    'c',
  ),
  q(
    'balizamiento',
    'Una marca cardinal Norte indica que las aguas seguras están:',
    [
      { id: 'a', text: 'Al norte de la marca' },
      { id: 'b', text: 'Al sur de la marca' },
      { id: 'c', text: 'Al oeste de la marca' },
      { id: 'd', text: 'Al este de la marca' },
    ],
    'a',
  ),
  q(
    'balizamiento',
    '¿Qué marca de tope es típica en una marca cardinal (en general)?',
    [
      { id: 'a', text: 'Dos conos negros' },
      { id: 'b', text: 'Un cilindro rojo' },
      { id: 'c', text: 'Una esfera verde' },
      { id: 'd', text: 'Una cruz amarilla' },
    ],
    'a',
  ),
  q(
    'balizamiento',
    '¿Qué forma (si la hay) suele asociarse a la marca lateral de babor?',
    [
      { id: 'a', text: 'Cono apuntando hacia arriba' },
      { id: 'b', text: 'Cilíndrica (castillete/can)' },
      { id: 'c', text: 'Esférica' },
      { id: 'd', text: 'Cruz de San Andrés' },
    ],
    'b',
  ),
  q(
    'balizamiento',
    '¿Qué forma (si la hay) suele asociarse a la marca lateral de estribor?',
    [
      { id: 'a', text: 'Cono (tope hacia arriba)' },
      { id: 'b', text: 'Cilíndrica' },
      { id: 'c', text: 'Cuadrada' },
      { id: 'd', text: 'Esférica' },
    ],
    'a',
  ),
  q(
    'balizamiento',
    '¿Qué indica, por lo general, una boya con franjas negras y amarillas?',
    [
      { id: 'a', text: 'Marca especial' },
      { id: 'b', text: 'Marca cardinal' },
      { id: 'c', text: 'Marca de babor' },
      { id: 'd', text: 'Marca de aguas seguras' },
    ],
    'b',
  ),

  // 6) Reglamento de abordajes (10)
  q(
    'reglamento_abordajes',
    'Dos buques de propulsión mecánica se aproximan en rumbos opuestos. ¿Qué deben hacer normalmente?',
    [
      { id: 'a', text: 'Ambos caer a estribor' },
      { id: 'b', text: 'Ambos caer a babor' },
      { id: 'c', text: 'El de mayor eslora cede el paso' },
      { id: 'd', text: 'El más rápido mantiene rumbo y velocidad' },
    ],
    'a',
  ),
  q(
    'reglamento_abordajes',
    'En un cruce de dos buques de propulsión mecánica, ¿quién debe maniobrar para evitar abordaje?',
    [
      { id: 'a', text: 'El que tiene al otro por su estribor' },
      { id: 'b', text: 'El que tiene al otro por su babor' },
      { id: 'c', text: 'Siempre el de menor tamaño' },
      { id: 'd', text: 'Ninguno: ambos mantienen rumbo' },
    ],
    'a',
  ),
  q(
    'reglamento_abordajes',
    'Un buque que alcanza a otro por su popa, ¿qué situación es?',
    [
      { id: 'a', text: 'Situación de cruce' },
      { id: 'b', text: 'Situación de vuelta encontrada' },
      { id: 'c', text: 'Alcance (overtaking)' },
      { id: 'd', text: 'No aplica: no hay riesgo' },
    ],
    'c',
  ),
  q(
    'reglamento_abordajes',
    'En situación de alcance, ¿quién es el buque “que se mantiene apartado” (give-way)?',
    [
      { id: 'a', text: 'El buque alcanzado' },
      { id: 'b', text: 'El buque que alcanza' },
      { id: 'c', text: 'El de mayor calado' },
      { id: 'd', text: 'El que lleva velas' },
    ],
    'b',
  ),
  q(
    'reglamento_abordajes',
    '¿Qué luz muestra un buque a propulsión mecánica navegando de noche (además de las de costado y alcance)?',
    [
      { id: 'a', text: 'Una luz de tope (blanca) hacia proa' },
      { id: 'b', text: 'Una luz amarilla todo horizonte' },
      { id: 'c', text: 'Dos luces rojas todo horizonte' },
      { id: 'd', text: 'Una luz verde todo horizonte' },
    ],
    'a',
  ),
  q(
    'reglamento_abordajes',
    '¿Qué luces de costado (sidelights) se muestran por la noche?',
    [
      { id: 'a', text: 'Roja a estribor y verde a babor' },
      { id: 'b', text: 'Roja a babor y verde a estribor' },
      { id: 'c', text: 'Ambas blancas' },
      { id: 'd', text: 'Ambas amarillas' },
    ],
    'b',
  ),
  q(
    'reglamento_abordajes',
    '¿Qué señal acústica indica “caigo a estribor” (buques a la vista, maniobra)?',
    [
      { id: 'a', text: 'Un pitido corto' },
      { id: 'b', text: 'Dos pitidos cortos' },
      { id: 'c', text: 'Tres pitidos cortos' },
      { id: 'd', text: 'Un pitido largo' },
    ],
    'a',
  ),
  q(
    'reglamento_abordajes',
    '¿Qué señal acústica indica “máquinas atrás” (maniobrando con propulsión)?',
    [
      { id: 'a', text: 'Un pitido corto' },
      { id: 'b', text: 'Dos pitidos cortos' },
      { id: 'c', text: 'Tres pitidos cortos' },
      { id: 'd', text: 'Cinco pitidos cortos y rápidos' },
    ],
    'c',
  ),
  q(
    'reglamento_abordajes',
    'En niebla o visibilidad reducida, un buque de propulsión mecánica con arrancada suele emitir:',
    [
      { id: 'a', text: 'Un pitido largo cada 2 minutos' },
      { id: 'b', text: 'Dos pitidos cortos cada 10 segundos' },
      { id: 'c', text: 'Un pitido corto cada minuto' },
      { id: 'd', text: 'Tres pitidos largos cada 5 minutos' },
    ],
    'a',
  ),
  q(
    'reglamento_abordajes',
    '¿Qué obligación básica establece el RIPA/COLREG respecto a la vigilancia?',
    [
      { id: 'a', text: 'Vigilancia por radar solamente' },
      { id: 'b', text: 'Vigilancia eficaz por vista, oído y todos los medios disponibles' },
      { id: 'c', text: 'Vigilancia solo de día' },
      { id: 'd', text: 'Vigilancia solo en puertos' },
    ],
    'b',
  ),

  // 7) Maniobra y navegación (10)
  q(
    'maniobra_navegacion',
    '¿Qué efecto puede producir la hélice (especialmente con marcha atrás) sobre la popa en muchas embarcaciones?',
    [
      { id: 'a', text: 'Efecto abatimiento por el viento' },
      { id: 'b', text: 'Efecto de hélice (prop walk)' },
      { id: 'c', text: 'Efecto giroscópico del compás' },
      { id: 'd', text: 'Efecto Coriolis' },
    ],
    'b',
  ),
  q(
    'maniobra_navegacion',
    'Para atracar con viento de través fuerte, una técnica habitual es:',
    [
      { id: 'a', text: 'Entrar sin arrancada' },
      { id: 'b', text: 'Entrar con control de arrancada y usar el motor para mantener gobierno' },
      { id: 'c', text: 'Apagar el motor y dejar que el viento lleve el barco' },
      { id: 'd', text: 'Fondear en mitad de la maniobra para frenar' },
    ],
    'b',
  ),
  q(
    'maniobra_navegacion',
    '¿Qué significa “abatimiento” en navegación?',
    [
      { id: 'a', text: 'Deriva producida por viento lateral' },
      { id: 'b', text: 'Cambio de rumbo voluntario' },
      { id: 'c', text: 'Velocidad sobre el fondo' },
      { id: 'd', text: 'Fuerza del motor a máxima potencia' },
    ],
    'a',
  ),
  q(
    'maniobra_navegacion',
    'Al entrar en un puerto con canal estrecho, una recomendación general es:',
    [
      { id: 'a', text: 'Navegar lo más rápido posible para tener gobierno' },
      { id: 'b', text: 'Mantener velocidad segura y estar preparado para maniobrar' },
      { id: 'c', text: 'Cruzar por el centro sin vigilancia' },
      { id: 'd', text: 'No usar defensas para no rozar' },
    ],
    'b',
  ),
  q(
    'maniobra_navegacion',
    '¿Qué es el “gobierno” de una embarcación?',
    [
      { id: 'a', text: 'La capacidad de mantener rumbo y responder al timón' },
      { id: 'b', text: 'El documento de matriculación' },
      { id: 'c', text: 'El tipo de ancla' },
      { id: 'd', text: 'La altura del francobordo' },
    ],
    'a',
  ),
  q(
    'maniobra_navegacion',
    'En general, ¿qué ocurre con el radio de giro al aumentar la velocidad (manteniendo ángulo de timón)?',
    [
      { id: 'a', text: 'Suele disminuir' },
      { id: 'b', text: 'Suele aumentar indefinidamente' },
      { id: 'c', text: 'No cambia nunca' },
      { id: 'd', text: 'Depende solo del color del casco' },
    ],
    'a',
  ),
  q(
    'maniobra_navegacion',
    '¿Qué influencia tiene la corriente en una maniobra de atraque?',
    [
      { id: 'a', text: 'Ninguna' },
      { id: 'b', text: 'Puede desplazar el barco lateralmente y modificar la aproximación' },
      { id: 'c', text: 'Solo afecta a barcos a vela' },
      { id: 'd', text: 'Solo afecta de noche' },
    ],
    'b',
  ),
  q(
    'maniobra_navegacion',
    '¿Qué precaución es recomendable al dar marcha atrás cerca de otras embarcaciones?',
    [
      { id: 'a', text: 'Girar el timón al máximo y acelerar' },
      { id: 'b', text: 'Comprobar espacio libre y usar poca arrancada' },
      { id: 'c', text: 'No mirar popa nunca' },
      { id: 'd', text: 'Soltar un ancla para estabilizar' },
    ],
    'b',
  ),
  q(
    'maniobra_navegacion',
    'En una ciaboga (giro) en espacio reducido, ayuda especialmente:',
    [
      { id: 'a', text: 'Usar alternancia de avante/atrás y timón para pivotar' },
      { id: 'b', text: 'Desinflar las defensas' },
      { id: 'c', text: 'Cerrar el grifo de fondo' },
      { id: 'd', text: 'Subir el ancla a mitad' },
    ],
    'a',
  ),
  q(
    'maniobra_navegacion',
    '¿Qué se recomienda hacer con las defensas antes de atracar?',
    [
      { id: 'a', text: 'Guardarlas para que no estorben' },
      { id: 'b', text: 'Colocarlas a la altura adecuada del muelle y distribuirlas' },
      { id: 'c', text: 'Inflarlas al máximo siempre' },
      { id: 'd', text: 'Pintarlas para que combinen con el casco' },
    ],
    'b',
  ),

  // 8) Emergencias en la mar (10)
  q(
    'emergencias_mar',
    '¿Qué mensaje radiotelefónico corresponde a una situación de urgencia (no socorro)?',
    [
      { id: 'a', text: 'MAYDAY' },
      { id: 'b', text: 'PAN-PAN' },
      { id: 'c', text: 'SECURITÉ' },
      { id: 'd', text: 'QTH' },
    ],
    'b',
  ),
  q(
    'emergencias_mar',
    '¿Qué mensaje se usa para difundir avisos de seguridad a la navegación o meteorológicos?',
    [
      { id: 'a', text: 'SECURITÉ' },
      { id: 'b', text: 'PAN-PAN' },
      { id: 'c', text: 'MAYDAY' },
      { id: 'd', text: 'SOS (siempre)' },
    ],
    'a',
  ),
  q(
    'emergencias_mar',
    'Ante una vía de agua, una medida inmediata razonable es:',
    [
      { id: 'a', text: 'Aumentar velocidad para “secar” la sentina' },
      { id: 'b', text: 'Localizar la entrada, taponar si es posible y achicar' },
      { id: 'c', text: 'Apagar todas las bombas' },
      { id: 'd', text: 'Abrir todas las válvulas de fondo' },
    ],
    'b',
  ),
  q(
    'emergencias_mar',
    'En caso de abandono, ¿qué se recomienda llevar a la balsa si hay tiempo?',
    [
      { id: 'a', text: 'Una televisión portátil' },
      { id: 'b', text: 'Equipo de supervivencia y comunicaciones (p. ej., VHF portátil/EPIRB si procede)' },
      { id: 'c', text: 'Plomos de pesca' },
      { id: 'd', text: 'Un ancla de respeto' },
    ],
    'b',
  ),
  q(
    'emergencias_mar',
    '¿Cuál es una acción típica en un incendio en la sala de máquinas?',
    [
      { id: 'a', text: 'Abrir el compartimento para ver el fuego' },
      { id: 'b', text: 'Cerrar ventilación y usar extinción adecuada sin aportar oxígeno' },
      { id: 'c', text: 'Echar agua de mar a presión sin criterio' },
      { id: 'd', text: 'Seguir navegando a máxima velocidad' },
    ],
    'b',
  ),
  q(
    'emergencias_mar',
    'Si se pierde el gobierno (fallo de timón), una medida inicial puede ser:',
    [
      { id: 'a', text: 'Detener la embarcación y evaluar alternativas (timón de emergencia, motor, vela)' },
      { id: 'b', text: 'Entrar a puerto a toda velocidad' },
      { id: 'c', text: 'Cortar la radio' },
      { id: 'd', text: 'Fondear siempre, aunque no haya fondo' },
    ],
    'a',
  ),
  q(
    'emergencias_mar',
    'En “hombre al agua”, además de la maniobra, ¿qué elemento se debe lanzar cuanto antes?',
    [
      { id: 'a', text: 'Un cabo al aire' },
      { id: 'b', text: 'Un aro salvavidas o elemento flotante' },
      { id: 'c', text: 'La ancla' },
      { id: 'd', text: 'La carta náutica' },
    ],
    'b',
  ),
  q(
    'emergencias_mar',
    'Una señal pirotécnica adecuada para indicar posición a aeronaves es:',
    [
      { id: 'a', text: 'Bengala de mano usada dentro de la cabina' },
      { id: 'b', text: 'Cohete con luz paracaídas' },
      { id: 'c', text: 'Petardo de fiesta' },
      { id: 'd', text: 'Humo negro' },
    ],
    'b',
  ),
  q(
    'emergencias_mar',
    '¿Qué información es clave en un mensaje de socorro?',
    [
      { id: 'a', text: 'Color favorito del patrón' },
      { id: 'b', text: 'Posición, naturaleza de la emergencia y asistencia requerida' },
      { id: 'c', text: 'Marca del motor' },
      { id: 'd', text: 'Número de amarre en el puerto base' },
    ],
    'b',
  ),
  q(
    'emergencias_mar',
    '¿Qué es una radiobaliza (EPIRB), a grandes rasgos?',
    [
      { id: 'a', text: 'Un tipo de ancla' },
      { id: 'b', text: 'Un equipo que emite señal de socorro para facilitar la localización' },
      { id: 'c', text: 'Un compás de marcaciones' },
      { id: 'd', text: 'Una linterna de mano' },
    ],
    'b',
  ),

  // 9) Meteorología (10)
  q(
    'meteorologia',
    '¿Qué indica, en general, una bajada rápida de presión en el barómetro?',
    [
      { id: 'a', text: 'Mejora del tiempo' },
      { id: 'b', text: 'Aproximación de borrasca o mal tiempo' },
      { id: 'c', text: 'Ausencia total de viento' },
      { id: 'd', text: 'Cambio de marea únicamente' },
    ],
    'b',
  ),
  q(
    'meteorologia',
    '¿Qué son las isobaras en un mapa meteorológico?',
    [
      { id: 'a', text: 'Líneas de igual presión' },
      { id: 'b', text: 'Líneas de igual temperatura del agua' },
      { id: 'c', text: 'Líneas de igual salinidad' },
      { id: 'd', text: 'Líneas de igual profundidad' },
    ],
    'a',
  ),
  q(
    'meteorologia',
    '¿Qué suele indicar un frente frío al paso?',
    [
      { id: 'a', text: 'Cielo totalmente despejado sin cambios' },
      { id: 'b', text: 'Descenso de temperatura y cambios bruscos con chubascos' },
      { id: 'c', text: 'Aumento de temperatura y nieblas persistentes' },
      { id: 'd', text: 'Desaparición del viento permanentemente' },
    ],
    'b',
  ),
  q(
    'meteorologia',
    '¿Cómo se llama el viento que sopla del mar hacia tierra durante el día en zonas costeras?',
    [
      { id: 'a', text: 'Brisa marina' },
      { id: 'b', text: 'Brisa terral' },
      { id: 'c', text: 'Cierzo' },
      { id: 'd', text: 'Mistral' },
    ],
    'a',
  ),
  q(
    'meteorologia',
    '¿Qué fenómeno es una “racha” (gust)?',
    [
      { id: 'a', text: 'Un aumento repentino y breve de la velocidad del viento' },
      { id: 'b', text: 'Un cambio lento del nivel del mar' },
      { id: 'c', text: 'Una corriente permanente' },
      { id: 'd', text: 'Un tipo de nube baja' },
    ],
    'a',
  ),
  q(
    'meteorologia',
    '¿Qué se entiende por “mar de fondo”?',
    [
      { id: 'a', text: 'Olas generadas localmente por el viento actual' },
      { id: 'b', text: 'Olas generadas lejos que llegan a la zona aunque aquí haya poco viento' },
      { id: 'c', text: 'Olas en un lago' },
      { id: 'd', text: 'Olas causadas solo por corrientes' },
    ],
    'b',
  ),
  q(
    'meteorologia',
    'En la escala Beaufort, ¿qué magnitud se describe principalmente?',
    [
      { id: 'a', text: 'La velocidad/fuerza del viento' },
      { id: 'b', text: 'La altura del sol' },
      { id: 'c', text: 'La salinidad' },
      { id: 'd', text: 'La profundidad' },
    ],
    'a',
  ),
  q(
    'meteorologia',
    '¿Qué suele asociarse a anticiclón (alta presión), en términos generales?',
    [
      { id: 'a', text: 'Tiempo más estable' },
      { id: 'b', text: 'Temporal garantizado' },
      { id: 'c', text: 'Tormentas eléctricas continuas' },
      { id: 'd', text: 'Vientos huracanados permanentes' },
    ],
    'a',
  ),
  q(
    'meteorologia',
    '¿Qué nube alta y filamentosa suele anunciar cambios de tiempo?',
    [
      { id: 'a', text: 'Cúmulo' },
      { id: 'b', text: 'Cirro' },
      { id: 'c', text: 'Estrato' },
      { id: 'd', text: 'Nimboestrato' },
    ],
    'b',
  ),
  q(
    'meteorologia',
    'La “visibilidad” en navegación se refiere a:',
    [
      { id: 'a', text: 'La distancia a la que pueden distinguirse objetos' },
      { id: 'b', text: 'La profundidad del agua' },
      { id: 'c', text: 'La intensidad de la corriente' },
      { id: 'd', text: 'La temperatura del motor' },
    ],
    'a',
  ),

  // 10) Teoría de la navegación (10)
  q(
    'teoria_navegacion',
    '¿Qué unidad se usa para expresar la velocidad de un buque en navegación?',
    [
      { id: 'a', text: 'Kilovatios' },
      { id: 'b', text: 'Nudos' },
      { id: 'c', text: 'Metros' },
      { id: 'd', text: 'Grados' },
    ],
    'b',
  ),
  q(
    'teoria_navegacion',
    '¿Cuántos minutos de arco hay en un grado?',
    [
      { id: 'a', text: '10' },
      { id: 'b', text: '30' },
      { id: 'c', text: '60' },
      { id: 'd', text: '100' },
    ],
    'c',
  ),
  q(
    'teoria_navegacion',
    'La latitud se mide desde:',
    [
      { id: 'a', text: 'El meridiano de Greenwich' },
      { id: 'b', text: 'El ecuador' },
      { id: 'c', text: 'El polo norte' },
      { id: 'd', text: 'El trópico de Cáncer' },
    ],
    'b',
  ),
  q(
    'teoria_navegacion',
    'La longitud se mide desde:',
    [
      { id: 'a', text: 'El ecuador' },
      { id: 'b', text: 'El meridiano de Greenwich' },
      { id: 'c', text: 'El meridiano local del puerto' },
      { id: 'd', text: 'El trópico de Capricornio' },
    ],
    'b',
  ),
  q(
    'teoria_navegacion',
    '¿Qué es la “derrota” en navegación?',
    [
      { id: 'a', text: 'El rumbo o trayectoria prevista/seguida sobre la carta' },
      { id: 'b', text: 'La velocidad instantánea del viento' },
      { id: 'c', text: 'La profundidad mínima' },
      { id: 'd', text: 'El tipo de ancla' },
    ],
    'a',
  ),
  q(
    'teoria_navegacion',
    '¿Qué es la “deriva” (en general)?',
    [
      { id: 'a', text: 'Desplazamiento lateral debido a viento/corriente respecto al rumbo' },
      { id: 'b', text: 'Cambio voluntario de rumbo por el timón' },
      { id: 'c', text: 'Aumento de revoluciones del motor' },
      { id: 'd', text: 'Reducción de calado' },
    ],
    'a',
  ),
  q(
    'teoria_navegacion',
    '¿Qué significa ETA en navegación?',
    [
      { id: 'a', text: 'Eslora Total Aproximada' },
      { id: 'b', text: 'Estimated Time of Arrival (hora estimada de llegada)' },
      { id: 'c', text: 'Eje de Timón Ajustado' },
      { id: 'd', text: 'Equipo Técnico Auxiliar' },
    ],
    'b',
  ),
  q(
    'teoria_navegacion',
    '¿Qué instrumento se usa para medir la profundidad de forma tradicional con plomo y línea?',
    [
      { id: 'a', text: 'Escandallo' },
      { id: 'b', text: 'Barómetro' },
      { id: 'c', text: 'Anemómetro' },
      { id: 'd', text: 'Cronómetro' },
    ],
    'a',
  ),
  q(
    'teoria_navegacion',
    '¿Qué es el “rumbo” de una embarcación?',
    [
      { id: 'a', text: 'La dirección hacia la que apunta la proa' },
      { id: 'b', text: 'La distancia recorrida en una hora' },
      { id: 'c', text: 'La altura del oleaje' },
      { id: 'd', text: 'La marca del motor' },
    ],
    'a',
  ),
  q(
    'teoria_navegacion',
    '¿Qué magnitud expresa la “distancia” en carta náutica usando minutos de latitud?',
    [
      { id: 'a', text: '1 minuto de latitud = 1 milla náutica' },
      { id: 'b', text: '1 grado de latitud = 1 milla náutica' },
      { id: 'c', text: '1 minuto de longitud = 1 milla náutica siempre' },
      { id: 'd', text: '1 nudo = 1 milla' },
    ],
    'a',
  ),

  // 11) Carta de navegación (10)
  q(
    'carta_navegacion',
    '¿Qué representa la escala de una carta náutica?',
    [
      { id: 'a', text: 'La altura de las olas' },
      { id: 'b', text: 'La relación entre distancia en carta y distancia real' },
      { id: 'c', text: 'La velocidad del barco' },
      { id: 'd', text: 'La temperatura del agua' },
    ],
    'b',
  ),
  q(
    'carta_navegacion',
    '¿Dónde se miden normalmente las distancias en una carta náutica?',
    [
      { id: 'a', text: 'En la escala gráfica solamente' },
      { id: 'b', text: 'En la escala de latitudes (margen) usando minutos' },
      { id: 'c', text: 'En la escala de longitudes siempre' },
      { id: 'd', text: 'En el centro de la rosa de los vientos' },
    ],
    'b',
  ),
  q(
    'carta_navegacion',
    '¿Qué indica un sondaje (número) en una carta náutica?',
    [
      { id: 'a', text: 'La altura del faro' },
      { id: 'b', text: 'La profundidad en ese punto (según datum)' },
      { id: 'c', text: 'La velocidad de la corriente' },
      { id: 'd', text: 'La dirección del viento' },
    ],
    'b',
  ),
  q(
    'carta_navegacion',
    '¿Para qué sirve la rosa de los vientos/compás en una carta?',
    [
      { id: 'a', text: 'Para estimar la salinidad' },
      { id: 'b', text: 'Para orientar y tomar rumbos/direcciones' },
      { id: 'c', text: 'Para medir profundidad' },
      { id: 'd', text: 'Para medir la temperatura' },
    ],
    'b',
  ),
  q(
    'carta_navegacion',
    '¿Qué significa, en general, la abreviatura “Fl” en características de luces en carta?',
    [
      { id: 'a', text: 'Luz fija' },
      { id: 'b', text: 'Luz centelleante (flash)' },
      { id: 'c', text: 'Luz de sector siempre roja' },
      { id: 'd', text: 'Luz apagada' },
    ],
    'b',
  ),
  q(
    'carta_navegacion',
    '¿Qué instrumento se utiliza para trazar rumbos sobre la carta?',
    [
      { id: 'a', text: 'Escandallo' },
      { id: 'b', text: 'Transportador/regla de navegación' },
      { id: 'c', text: 'Barómetro' },
      { id: 'd', text: 'Sextante (solo)' },
    ],
    'b',
  ),
  q(
    'carta_navegacion',
    '¿Qué indica una línea de sonda/curva batimétrica (isóbata) en carta?',
    [
      { id: 'a', text: 'Igual temperatura' },
      { id: 'b', text: 'Igual profundidad' },
      { id: 'c', text: 'Igual presión' },
      { id: 'd', text: 'Igual rumbo' },
    ],
    'b',
  ),
  q(
    'carta_navegacion',
    '¿Qué se representa normalmente con una “X” o símbolo de peligro en carta?',
    [
      { id: 'a', text: 'Un área de pesca autorizada' },
      { id: 'b', text: 'Un peligro/obstrucción (según simbología)' },
      { id: 'c', text: 'Una ruta recomendada obligatoria siempre' },
      { id: 'd', text: 'Un lugar para fondear seguro siempre' },
    ],
    'b',
  ),
  q(
    'carta_navegacion',
    '¿Qué dato es esencial para interpretar profundidades: el “datum” o referencia vertical suele ser:',
    [
      { id: 'a', text: 'Altura de pleamar' },
      { id: 'b', text: 'Cero hidrográfico (referencia de mareas)' },
      { id: 'c', text: 'Nivel de la cubierta' },
      { id: 'd', text: 'Altura del mástil' },
    ],
    'b',
  ),
  q(
    'carta_navegacion',
    '¿Qué se debe hacer periódicamente con las cartas para mantenerlas útiles?',
    [
      { id: 'a', text: 'Pintarlas de nuevo' },
      { id: 'b', text: 'Corregirlas/actualizarlas con avisos a los navegantes cuando aplique' },
      { id: 'c', text: 'Recortarlas para que ocupen menos' },
      { id: 'd', text: 'Mojarlas para que no se rompan' },
    ],
    'b',
  ),
];

function validateQuestions() {
  const counts = new Map(topics.map((t) => [t.id, 0]));
  for (const item of questions) {
    if (!counts.has(item.topicId)) throw new Error(`Question has unknown topicId: ${item.topicId}`);
    counts.set(item.topicId, counts.get(item.topicId) + 1);

    const ids = item.answers.map((a) => a.id);
    const required = ['a', 'b', 'c', 'd'];
    for (const r of required) {
      if (!ids.includes(r)) throw new Error(`Question missing answer id "${r}": ${item.statement}`);
    }
    if (!required.includes(item.correctAnswerId)) {
      throw new Error(`Invalid correctAnswerId "${item.correctAnswerId}": ${item.statement}`);
    }
  }

  const wrong = [];
  for (const [topicId, count] of counts.entries()) {
    if (count !== 10) wrong.push(`${topicId}=${count}`);
  }
  if (wrong.length) {
    throw new Error(`Expected 10 questions per topic. Offenders: ${wrong.join(', ')}`);
  }
}

// ── Seed function ─────────────────────────────────────────────────────────
async function seed() {
  validateQuestions();
  if (VALIDATE_ONLY) {
    console.log(`✓ Validation OK: ${questions.length} questions (10 por tema)`);
    process.exit(0);
  }

  console.log('Seeding topics...');
  const topicBatch = db.batch();
  for (const t of topics) {
    const { id, ...data } = t;
    topicBatch.set(db.collection('topics').doc(id), data);
  }
  await topicBatch.commit();
  console.log(`✓ ${topics.length} topics written`);

  console.log('Seeding questions (10x11)...');
  const qBatch = db.batch();
  for (const item of questions) {
    const ref = db.collection('questions').doc();
    qBatch.set(ref, { ...item, createdAt: admin.firestore.FieldValue.serverTimestamp() });
  }
  await qBatch.commit();
  console.log(`✓ ${questions.length} questions written`);

  console.log('\nDone!');
  process.exit(0);
}

seed().catch((e) => {
  console.error(e);
  process.exit(1);
});
