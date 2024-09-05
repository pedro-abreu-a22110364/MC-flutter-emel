enum TipoParque {
  SUPERFICIE,
  ESTRUTURA
}

TipoParque? stringToTipoParque(String? str) {
  if (str == null) return null;
  switch (str) {
    case 'Superfície':
      return TipoParque.SUPERFICIE;
    case 'Estrutura':
      return TipoParque.ESTRUTURA;
    default:
      return null;
  }
}