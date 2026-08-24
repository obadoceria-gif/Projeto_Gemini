
const products = {
  "caixas": [
    { "id": "cx001", "name": "Caixa com 4 doces", "capacity": 4, "price": 20.00 },
    { "id": "cx002", "name": "Caixa com 6 doces", "capacity": 6, "price": 30.00 },
    { "id": "cx003", "name": "Caixa com 12 doces", "capacity": 12, "price": 60.00 }
  ],
  "kitsPresenteaveis": [
    { "id": "kp001", "name": "Mini Naked Cake", "price": 45.00 },
    { "id": "kp002", "name": "Uvas Verdes (200g)", "price": 15.00 },
    { "id": "kp003", "name": "Morangos Frescos (200g)", "price": 18.00 }
  ],
  "opcionais": [
    { "id": "op001", "name": "Cartão Personalizado", "price": 5.00 },
    { "id": "op002", "name": "Embalagem de Presente", "price": 10.00 }
  ]
};

export function getProducts() {
  return products;
}

export function validateProducts(products) {
  // Implementar lógica de validação se necessário
  return true;
}
