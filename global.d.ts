declare module '*.css';
declare module '*.scss';
declare module '*.sass';
declare module '*.svg';
declare module '*.png';
declare module '*.jpg';
declare module '*.jpeg';
declare module '*.gif';
declare module '*.webp';
declare module '*.avif';
declare module '*.ico';

declare global {
  interface Window {
    currentSlide?: (n: number) => void;
    __navRefactor?: any;
    handleGoogleSuggestions?: (data: any) => void;
    grecaptcha?: Grecaptcha;
  }

  type ChatMessage = {
    role: 'user' | 'bot' | 'assistant' | 'system' | string;
    text: string;
    content?: string;
  };
}

export {};
