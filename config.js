// Connexion Supabase d'ELEVEN ACADEMY.
// Tant que les deux valeurs sont vides, l'application garde la progression sur l'appareil (pas de connexion).
// supabaseKey = la clé publique "anon" (ou "publishable") du projet : elle est faite pour être publique,
// la sécurité repose sur les règles d'accès (RLS) de supabase/schema.sql.
window.EA_CONFIG = {
  supabaseUrl: "https://pwziiledutebgoyuvflm.supabase.co",
  // true une fois le modèle d'e-mail Supabase passé au code à 6 chiffres
  loginCode: true,
  // true une fois la fonction Supabase « arbitre » installée
  arbitre: true,
  arbitreFn: "clever-handler",
  supabaseKey: "sb_publishable_kBA3GSSDoWY3QwUARbXWkg_uUhguGZs"
};
