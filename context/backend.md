# PP

La app permitirá la realización de exámenes tipo test para patrón de recreo.
El backend + database se realizará con Firebase.

## Database

- Cada pregunta tiene
    - 1 enunciado
    - 4 respuestas (una de ellas es correcta)
    - 1 tema asignado

- Los temas posibles son:
    - Nomenclatura náutica
    - Elementos de amarre y fondeo
    - Seguridad en la mar Legislación
    - Balizamiento, Reglamento de abordajes
    - Maniobra y navegación
    - Emergencias en la mar
    - Meteorología
    - Teoría de la navegación
    - Carta de navegación
    
- Los exámenes tienen que guardar las preguntas que recogen:
   - Tema "Nomenclatura náutica": 4 preguntas
            - Tema "Elementos de amarre y fondeo": 2 preguntas
            - Tema "Seguridad en la mar": 4 preguntas
            - Tema "Legislación": 2 preguntas
            - Tema "Balizamiento": 5 preguntas
            - Tema "Reglamento de abordajes": 10 preguntas
            - Tema "Maniobra y navegación": 2 preguntas
            - Tema "Emergencias en la mar": 3 preguntas
            - Tema "Meteorología": 4 preguntas
            - Tema "Teoría de la navegación": 5 preguntas
            - Tema "Carta de navegación": 4 preguntas

## Backend

Lo necesario para conectar el forntend especificado en frontend.md