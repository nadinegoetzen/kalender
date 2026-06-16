// ============================================================
//  Supabase-Anbindung für Adventskalender / Holiday Week
//  (passwortloser Login — analog zum Tippspiel)
//
//  Diese zwei Werte sind ÖFFENTLICH und dürfen im Frontend stehen.
//  Der geheime service_role / Secret-Key gehört NICHT hierher.
// ============================================================
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

export const SUPABASE_URL = "https://jvlzqzdmpuijamdcnjvw.supabase.co";
export const SUPABASE_KEY = "sb_publishable_czlpiUKiM4cW7nmYOKYvZA_iLhjWxGQ";
export const sb = createClient(SUPABASE_URL, SUPABASE_KEY);

// ---- Anmeldung / Login (Magic-Link + 6-stelliger Code) ----
// Erstanmeldung: legt Nutzer an und übergibt Newsletter-Einwilligung + Sprache.
export async function registerOrLogin(email, { newsletter = false, lang = "de", isNew = true } = {}) {
  const options = isNew
    ? { shouldCreateUser: true, data: { newsletter_consent: !!newsletter, lang, display_name: "Teilnehmer" } }
    : { shouldCreateUser: false };
  return sb.auth.signInWithOtp({ email, options });
}
// Code aus der E-Mail bestätigen (Alternative zum Magic-Link)
export async function verifyCode(email, token) {
  return sb.auth.verifyOtp({ email, token, type: "email" });
}
export async function currentUser() {
  const { data: { user } } = await sb.auth.getUser();
  return user;
}
export async function logout() { return sb.auth.signOut(); }

// ---- Türchen-Inhalte (vom Admin gepflegt) ----
export async function getDoors(campaign) {
  return sb.from("doors").select("*").eq("campaign", campaign).order("day");
}

// ---- Teilnahme speichern (eine pro Nutzer & Türchen) ----
export async function saveEntry({ campaign, day, answerIdx, isCorrect, sizeValue }) {
  const user = await currentUser();
  if (!user) throw new Error("nicht eingeloggt");
  return sb.from("entries").upsert(
    { campaign, day, user_id: user.id, answer_idx: answerIdx, is_correct: isCorrect, size_value: sizeValue },
    { onConflict: "campaign,day,user_id" }
  );
}
export async function myEntries(campaign) {
  const user = await currentUser();
  if (!user) return { data: [] };
  return sb.from("entries").select("*").eq("campaign", campaign).eq("user_id", user.id);
}
