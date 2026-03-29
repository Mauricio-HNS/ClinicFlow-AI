import { createContext, useContext, useMemo, useState, type PropsWithChildren } from "react";
import { messages } from "./messages";
import type { LanguageCode } from "./types";

const STORAGE_KEY = "clinicflow-admin-language";

type LanguageContextValue = {
  language: LanguageCode;
  setLanguage: (language: LanguageCode) => void;
  t: (typeof messages)[LanguageCode];
  availableLanguages: Array<{ code: LanguageCode; label: string }>;
};

const LanguageContext = createContext<LanguageContextValue | null>(null);

function getInitialLanguage(): LanguageCode {
  if (typeof window === "undefined") {
    return "pt";
  }

  const storedLanguage = window.localStorage.getItem(STORAGE_KEY);

  if (storedLanguage === "pt" || storedLanguage === "en" || storedLanguage === "es") {
    return storedLanguage;
  }

  return "pt";
}

export function LanguageProvider({ children }: PropsWithChildren) {
  const [language, setLanguageState] = useState<LanguageCode>(getInitialLanguage);

  const value = useMemo<LanguageContextValue>(() => {
    const setLanguage = (nextLanguage: LanguageCode) => {
      setLanguageState(nextLanguage);
      window.localStorage.setItem(STORAGE_KEY, nextLanguage);
    };

    return {
      language,
      setLanguage,
      t: messages[language],
      availableLanguages: Object.entries(messages).map(([code, dictionary]) => ({
        code: code as LanguageCode,
        label: dictionary.label
      }))
    };
  }, [language]);

  return <LanguageContext.Provider value={value}>{children}</LanguageContext.Provider>;
}

export function useLanguage() {
  const context = useContext(LanguageContext);

  if (!context) {
    throw new Error("useLanguage deve ser usado dentro de LanguageProvider.");
  }

  return context;
}
