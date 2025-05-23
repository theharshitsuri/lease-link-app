import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://zevjpoawnfmkrbgyualp.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpldmpwb2F3bmZta3JiZ3l1YWxwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQwNjY3MTQsImV4cCI6MjA1OTY0MjcxNH0.uh8eqnRapgsI61UHxKO4JLpd9veLLRg1TdI89ogkuvU';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
