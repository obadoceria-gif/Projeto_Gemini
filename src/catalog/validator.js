/**
 * Validação estrutural do Modelo Mestre de Catálogo.
 * Não depende da interface e não altera dados recebidos.
 */

function isPlainObject(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

function isNonEmptyString(value) {
  return typeof value === 'string' && value.trim().length > 0;
}

function isFiniteNonNegativeNumber(value) {
  return Number.isFinite(value) && value >= 0;
}

function collectDuplicateIds(items, label, errors) {
  const seen = new Set();

  for (const item of items) {
    if (!isPlainObject(item) || !isNonEmptyString(item.id)) {
      errors.push(`${label}: registro sem "id" válido.`);
      continue;
    }

    if (seen.has(item.id)) {
      errors.push(`${label}: id duplicado "${item.id}".`);
    }

    seen.add(item.id);
  }
}

function validateConfig(config, errors, warnings) {
  if (!isPlainObject(config)) {
    errors.push('config.json: conteúdo deve ser um objeto.');
    return;
  }

  if (!Number.isInteger(config.schemaVersion) || config.schemaVersion < 1) {
    errors.push('config.json: "schemaVersion" deve ser um inteiro >= 1.');
  }

  if (!isNonEmptyString(config.catalogVersion)) {
    errors.push('config.json: "catalogVersion" é obrigatório.');
  }

  if (!isPlainObject(config.store)) {
    errors.push('config.json: "store" é obrigatório.');
    return;
  }

  if (!isNonEmptyString(config.store.name)) {
    errors.push('config.json: "store.name" é obrigatório.');
  }

  if (!isNonEmptyString(config.store.whatsapp)) {
    errors.push('config.json: "store.whatsapp" é obrigatório.');
  } else if (!/^\d{10,15}$/.test(config.store.whatsapp)) {
    warnings.push('config.json: "store.whatsapp" deve conter apenas dígitos, incluindo DDI/DDD.');
  }
}

function validateCategories(categories, errors) {
  if (!Array.isArray(categories)) {
    errors.push('categories.json: conteúdo deve ser um array.');
    return;
  }

  collectDuplicateIds(categories, 'categories.json', errors);

  for (const category of categories) {
    if (!isPlainObject(category)) continue;

    if (!isNonEmptyString(category.nome)) {
      errors.push(`categories.json: categoria "${category.id ?? '?'}" sem nome válido.`);
    }

    if (!Number.isFinite(category.ordem)) {
      errors.push(`categories.json: categoria "${category.id ?? '?'}" sem ordem numérica.`);
    }
  }
}

function validateFlavors(flavors, categoryIds, errors) {
  if (!Array.isArray(flavors)) {
    errors.push('flavors.json: conteúdo deve ser um array.');
    return;
  }

  collectDuplicateIds(flavors, 'flavors.json', errors);

  for (const flavor of flavors) {
    if (!isPlainObject(flavor)) continue;

    if (!isNonEmptyString(flavor.nome)) {
      errors.push(`flavors.json: sabor "${flavor.id ?? '?'}" sem nome válido.`);
    }

    if (!categoryIds.has(flavor.categoriaId)) {
      errors.push(
        `flavors.json: sabor "${flavor.id ?? '?'}" referencia categoria inexistente "${flavor.categoriaId}".`
      );
    }

    if (!isFiniteNonNegativeNumber(flavor.preco)) {
      errors.push(`flavors.json: sabor "${flavor.id ?? '?'}" possui preço inválido.`);
    }
  }
}

function validateBoxes(boxes, errors) {
  if (!Array.isArray(boxes)) {
    errors.push('boxes.json: conteúdo deve ser um array.');
    return;
  }

  collectDuplicateIds(boxes, 'boxes.json', errors);

  for (const box of boxes) {
    if (!isPlainObject(box)) continue;

    if (!isNonEmptyString(box.nome)) {
      errors.push(`boxes.json: caixa "${box.id ?? '?'}" sem nome válido.`);
    }

    if (!Number.isInteger(box.capacidade) || box.capacidade <= 0) {
      errors.push(`boxes.json: caixa "${box.id ?? '?'}" possui capacidade inválida.`);
    }

    if (!['montavel', 'fechada'].includes(box.tipo)) {
      errors.push(`boxes.json: caixa "${box.id ?? '?'}" possui tipo inválido "${box.tipo}".`);
    }

    if (box.tipo === 'montavel') {
      if (!Number.isInteger(box.maxSabores) || box.maxSabores <= 0) {
        errors.push(`boxes.json: caixa montável "${box.id ?? '?'}" precisa de "maxSabores" válido.`);
      }
    }

    if (box.tipo === 'fechada' && !isFiniteNonNegativeNumber(box.precoFixo)) {
      errors.push(`boxes.json: caixa fechada "${box.id ?? '?'}" precisa de "precoFixo" válido.`);
    }
  }
}

function validateOptions(options, errors) {
  if (!Array.isArray(options)) {
    errors.push('options.json: conteúdo deve ser um array.');
    return;
  }

  collectDuplicateIds(options, 'options.json', errors);

  for (const option of options) {
    if (!isPlainObject(option)) continue;

    if (!isNonEmptyString(option.nome)) {
      errors.push(`options.json: opcional "${option.id ?? '?'}" sem nome válido.`);
    }

    if (!isFiniteNonNegativeNumber(option.preco)) {
      errors.push(`options.json: opcional "${option.id ?? '?'}" possui preço inválido.`);
    }
  }
}

function validateProducts(products, optionIds, errors) {
  if (!Array.isArray(products)) {
    errors.push('products.json: conteúdo deve ser um array.');
    return;
  }

  collectDuplicateIds(products, 'products.json', errors);

  for (const product of products) {
    if (!isPlainObject(product)) continue;

    if (!isNonEmptyString(product.nome)) {
      errors.push(`products.json: produto "${product.id ?? '?'}" sem nome válido.`);
    }

    if (!isFiniteNonNegativeNumber(product.preco)) {
      errors.push(`products.json: produto "${product.id ?? '?'}" possui preço inválido.`);
    }

    if (Array.isArray(product.opcionaisPermitidos)) {
      for (const optionId of product.opcionaisPermitidos) {
        if (!optionIds.has(optionId)) {
          errors.push(
            `products.json: produto "${product.id ?? '?'}" referencia opcional inexistente "${optionId}".`
          );
        }
      }
    }
  }
}

function validateCombos(combos, errors) {
  if (!Array.isArray(combos)) {
    errors.push('combos.json: conteúdo deve ser um array.');
    return;
  }

  collectDuplicateIds(combos, 'combos.json', errors);
}

export function validateCatalog(catalog) {
  const errors = [];
  const warnings = [];

  if (!isPlainObject(catalog)) {
    return {
      valid: false,
      errors: ['Catálogo carregado deve ser um objeto.'],
      warnings
    };
  }

  const {
    config,
    categories,
    flavors,
    boxes,
    products,
    options,
    combos
  } = catalog;

  validateConfig(config, errors, warnings);
  validateCategories(categories, errors);

  const categoryIds = new Set(
    Array.isArray(categories)
      ? categories.filter(isPlainObject).map(item => item.id).filter(isNonEmptyString)
      : []
  );

  const optionIds = new Set(
    Array.isArray(options)
      ? options.filter(isPlainObject).map(item => item.id).filter(isNonEmptyString)
      : []
  );

  validateFlavors(flavors, categoryIds, errors);
  validateBoxes(boxes, errors);
  validateOptions(options, errors);
  validateProducts(products, optionIds, errors);
  validateCombos(combos, errors);

  return {
    valid: errors.length === 0,
    errors,
    warnings
  };
}
