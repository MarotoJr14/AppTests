# Pantallas

El frontend se hará en Flutter, para que corra en Android e iOS, y opcionalmente en Windows y Mac.

La app tendrá las siguientes pantallas:

1. Login:
    - Login con correo electrónico y contraseña.
    - Enlace de "Olvidé mi contraseña".
        - Para recuperar la contraseña, se introducirá el correo electrónico.
            - Si existe en base de datos, se enviará un correo con un enlace para recuperar la contraseña.
            - Si no existe, se lanza error de que no existe un usuario con ese correo.

2. Home.
    - En la parte superior, imagen del logo de la empresa, y justo debajo el texto "Blue Saliling Tests"
    - Debajo, una sección de cards que llevan a las distintas secciones de la app:
        - Simulación de examen real
        - Preguntas aleatorias
        - Preguntas por tema
        - Estadísticas

*** A partir de este momento, en cada sección se mostrará una cabecera con el título de la sección. ***

3. Preguntas por tema.
    - Se abre una pantalla con 1 card por cada tema.
    - Cada card tendrá una imagen descriptiva del tema, y el nombre del tema.
        - Al hacer click en una card, se comienza una batería de preguntas del tema seleccionado que solo finaliza cuando el usuario seleccione "Terminar" o cuando se acaben las preguntas.
    - Al terminar la batería de preguntas, se abre una sección con la batería en el mismo orden, pero en modo de revisión.
    - Al finalizar la revisión de las preguntas, se vuelve a la pantalla de los cards de cada tema.

4. Preguntas aleatorias.
    - Se abre directamente una batería de preguntas aleatorias, sin filtrar por tema.
    - Al finalizar la batería de preguntas, se abre una sección igual, pero en modo de revisión.
    - Al finalizar la revisión de las preguntas, se vuelve a la pantalla principal.

5. Simulación de examen real.
    - Lo primero, asignas un nombre de examen. Si ya existe el nombre, se lanza error de que ya existe un examen con ese nombre.
    - Tras guardar el nombre del examen, se procede a realizar el examen.
        - Un examen consta de 45 preguntas, por este orden:
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

6. Pantalla de Pregunta
    - La cabecera mostrará la sección desde la que se ha accedido a esta pantalla.
    - Lo primero, se mostratá un pequeño label con el nombre del tema de la pregunta.
    - Solo en el caso de una simulación de examen, se mostrará debajo de ese label otro label a modo de recuento.
        - Por ejemplo, si estamos en la parte de "Nomenclatura náutica" este segundo label tendrá el texto "Pregunta 1/4" si es la 1º pregunta del tema que se muestra en el examen, y así sucesivamente hasta llegar al límite.
    - Debajo de este (o estos) label Se muestra una card con varias secciones:
        - Lo primero, el enunciado de la pregunta.
        - Un divider horizontal
        - Las 4 respuestas ordenadas aleatoriamente.
            - Las respuestas se mostrarán como "a) / b) / c) / d)" seguido del texto de la respuesta.
                - El usuario hará click sobre una de las 4 respuestas. Esa respuesta se sombreará de amarillo.
                - Si el usuario cambia de decisión y selecciona otra respuesta, la reapuesta anterior se deselecciona y la nueva se selecciona.
        - En la parte inferior de la pantalla, habrá 3 botones, en este orden:
            - < ANTERIOR
            - TERMINAR
            - SIGUIENTE >

7. Pantalla de Pregunta (en modo revisión)
    - Lo primero, se abre un Alert dialog que informa de "Has acertado x preguntas de un total de y." Con un botón de "ACEPTAR".
    - Al cerrar el alert dialog, se muestran las ptreguntas con las siguientes normas.
        - La respuesta correcta se sombrea de verde.
        - Además, si el usuario seleccionó una respuesta incorrecta, la respuesta que seleccionó se sombreará de rojo.

8. Estadísticas.
    - Se abre una pantalla con 2 secciones, que pueden ser cards.
        - La 1º sección es de Revisar exámenes.
            - Abre una pantalla con una lista de todos los exámenes realizados.
                - De cada examen se muestra el nombre y a la derecha el número de las preguntas acertadas y el de las preguntas totales. (x/y)
                - Al hacer click sobre uno de los exámenes, se abre la revisión de las preguntas de ese examen.
        - La 2º sección es de Preguntas de cada tema.
            - Se abre una pantalla con 1 card de cada tema, con la imagen, el nombre del tema, y un gráfico circular que representa el total de preguntas del tema, y estará relleno de verde en función del porcentaje de preguntas correctas que haya de ese tema.