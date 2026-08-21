"use client";
import React, { createContext, useContext, useState } from 'react';

type TypingContextValue = { isTyping: boolean; setIsTyping: (v: boolean) => void };
const TypingContext = createContext<TypingContextValue | undefined>(undefined);

export function TypingProvider({ children }: { children: React.ReactNode }) {
  const [isTyping, setIsTyping] = useState(false);
  return (
    <TypingContext.Provider value={{ isTyping, setIsTyping }}>
      {children}
    </TypingContext.Provider>
  );
}

export function useTyping() {
  const ctx = useContext(TypingContext);
  if (!ctx) throw new Error('useTyping must be used within a TypingProvider');
  return ctx;
}
