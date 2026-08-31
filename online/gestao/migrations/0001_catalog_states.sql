PRAGMA foreign_keys = ON;

-- ============================================================
-- OBA DOCERIA - CATALOGO ONLINE
-- REVISOES IMUTAVEIS + PONTEIROS DE ESTADO
-- ============================================================

CREATE TABLE IF NOT EXISTS catalog_revisions (
    revision_id TEXT PRIMARY KEY,
    payload_json TEXT NOT NULL,
    payload_sha256 TEXT NOT NULL,
    source TEXT NOT NULL,
    created_at TEXT NOT NULL,
    created_by TEXT NOT NULL DEFAULT 'admin',

    CHECK (length(revision_id) >= 8),
    CHECK (length(payload_json) > 2),
    CHECK (length(payload_sha256) = 64)
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_catalog_revisions_sha256
ON catalog_revisions(payload_sha256);

-- ------------------------------------------------------------
-- Cada SLOT aponta para UMA revisao imutavel.
--
-- DRAFT     = ultima versao salva na Central
-- PREVIEW   = versao explicitamente promovida para revisao
-- PUBLISHED = unica versao considerada publicada pelo motor
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS catalog_slots (
    slot TEXT PRIMARY KEY,
    revision_id TEXT,
    updated_at TEXT NOT NULL,

    FOREIGN KEY (revision_id)
        REFERENCES catalog_revisions(revision_id)
        ON DELETE RESTRICT,

    CHECK (
        slot IN (
            'DRAFT',
            'PREVIEW',
            'PUBLISHED'
        )
    )
);

INSERT OR IGNORE INTO catalog_slots (
    slot,
    revision_id,
    updated_at
)
VALUES
    ('DRAFT', NULL, '1970-01-01T00:00:00.000Z'),
    ('PREVIEW', NULL, '1970-01-01T00:00:00.000Z'),
    ('PUBLISHED', NULL, '1970-01-01T00:00:00.000Z');

-- ------------------------------------------------------------
-- Log append-only de promocoes.
-- Nenhuma entrada deve ser editada ou apagada pela aplicacao.
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS catalog_promotions (
    promotion_id TEXT PRIMARY KEY,

    action TEXT NOT NULL,

    from_revision_id TEXT,
    to_revision_id TEXT NOT NULL,

    created_at TEXT NOT NULL,
    created_by TEXT NOT NULL DEFAULT 'admin',

    FOREIGN KEY (from_revision_id)
        REFERENCES catalog_revisions(revision_id)
        ON DELETE RESTRICT,

    FOREIGN KEY (to_revision_id)
        REFERENCES catalog_revisions(revision_id)
        ON DELETE RESTRICT,

    CHECK (
        action IN (
            'DRAFT_SAVED',
            'PREVIEW_CREATED',
            'PUBLISHED',
            'ROLLBACK'
        )
    )
);

CREATE INDEX IF NOT EXISTS idx_catalog_promotions_created_at
ON catalog_promotions(created_at);

-- ------------------------------------------------------------
-- Restricoes conceituais:
--
-- 1. catalog_revisions e append-only pela aplicacao.
-- 2. Salvar nunca altera PUBLISHED.
-- 3. Preview nunca altera PUBLISHED.
-- 4. Publicar altera PUBLISHED somente apos validacao.
-- 5. Rollback aponta PUBLISHED para revisao anterior existente.
-- 6. Nenhum payload publicado e sobrescrito.
-- ------------------------------------------------------------