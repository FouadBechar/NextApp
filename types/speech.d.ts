// Minimal SpeechRecognition typing for environments that expose webkitSpeechRecognition.
// This avoids depending on DOM lib variants that may not always include these types.
interface SpeechRecognition {
  lang: string;
  interimResults: boolean;
  start(): void;
  stop(): void;
  addEventListener(event: string, callback: (event: any) => void): void;
  removeEventListener(event: string, callback: (event: any) => void): void;
}

interface SpeechRecognitionEvent {
  results: any[];
}

declare interface Window {
  webkitSpeechRecognition?: {
    new (): SpeechRecognition;
  };
  SpeechRecognition?: {
    new (): SpeechRecognition;
  };
}
// Minimal typings for SpeechRecognition & SpeechRecognitionEvent when the
// environment lib doesn't include them (some TS lib variants omit them).
interface SpeechRecognitionEvent {
  results: any;
}

interface SpeechRecognition {
  lang: string;
  interimResults: boolean;
  start(): void;
  stop(): void;
  addEventListener(event: string, listener: (e: any) => void): void;
  removeEventListener(event: string, listener: (e: any) => void): void;
}

declare var SpeechRecognition: {
  new (): SpeechRecognition;
};
declare var webkitSpeechRecognition: {
  new (): SpeechRecognition;
};
