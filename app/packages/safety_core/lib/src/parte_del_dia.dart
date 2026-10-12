/// Parte del día: mañana 06:00-13:59, tarde 14:00-20:59, noche 21:00-05:59.
enum ParteDelDia { manana, tarde, noche }

ParteDelDia parteDelDia(int hora) {
  if (hora >= 6 && hora < 14) return ParteDelDia.manana;
  if (hora >= 14 && hora < 21) return ParteDelDia.tarde;
  return ParteDelDia.noche;
}
