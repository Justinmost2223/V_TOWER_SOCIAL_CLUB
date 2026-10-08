/* ==========================================================================
   CONFIGURACIÓN DE IDENTIDAD LEGAL Y PRIVACIDAD (LSSI-CE & RGPD)
   ========================================================================== */
window.LEGAL_ENTITY = {
  name: "V Tower Social Club",
  taxId: "No publicado por motivos de privacidad",
  address: "Por motivos de seguridad y privacidad de los datos personales, la dirección física y de identificación fiscal no se publica abiertamente en este portal web. Para cualquier solicitud legal, ejercicio de derechos RGPD o consulta oficial, puede ponerse en contacto directamente a través de nuestro correo oficial: vtowersocialclub@gmail.com"
};

/* ==========================================================================
   CONFIGURACIÓN DE CONEXIÓN CON SUPABASE
   ========================================================================== */
const SUPABASE_URL = 'https://jwrzitpiqjgmpbncuxjj.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_ImaJ7mpM7oAaM1X2Ct9ppQ_BB0NExRo';

// Inicialización global del cliente de Supabase
if (typeof supabase !== 'undefined') {
  window.supabaseClient = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
} else {
  console.warn("El SDK de Supabase aún no se ha cargado en esta página.");
}