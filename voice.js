window.onload = () => {

const mensaje = `
Hola.
Soy Alivé.
Tu guía turística accesible.

Estoy lista para acompañarte.

Puedes decir:

Iniciar recorrido.

Lugares cercanos.

Información cultural.

O emergencia.
`;

hablar(mensaje);

};

function hablar(texto){

const voz = new SpeechSynthesisUtterance(texto);

voz.lang = "es-PE";
voz.rate = 0.9;
voz.pitch = 1;

speechSynthesis.speak(voz);

}
