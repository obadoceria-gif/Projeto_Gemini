export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    /*
     * OBA DOCERIA - CENTRAL PRIVADA
     *
     * IMPORTANTE:
     * A autenticacao real sera aplicada na borda por
     * Cloudflare Access antes de liberar este Worker.
     *
     * Este codigo NAO implementa senha no navegador.
     */

    if (url.pathname === "/health") {
      return Response.json({
        application: "oba-cardapio-gestao",
        status: "ok",
        protectedBy: "cloudflare-access-required"
      });
    }

    if (!env.ASSETS) {
      return new Response(
        "Assets binding indisponivel.",
        { status: 503 }
      );
    }

    return env.ASSETS.fetch(request);
  }
};
