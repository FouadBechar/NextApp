"use client";

import React, { useState } from 'react';
import EyeIcon from '@/components/icons/eye';
import EyeOffIcon from '@/components/icons/eye-off';

type Props = React.InputHTMLAttributes<HTMLInputElement> & {
  inputRef?: React.LegacyRef<HTMLInputElement>;
  showToggle?: boolean;
};

export default function PasswordInput({ inputRef, showToggle = true, className = '', ...props }: Props) {
  const [visible, setVisible] = useState(false);

  return (
    <div className={`relative ${className}`}>
      <input
        ref={inputRef}
        {...props}
        type={visible ? 'text' : 'password'}
        className={`w-full pr-9 ${className}`}
      />
      {showToggle && (
        <button
          type="button"
          aria-label={visible ? 'Hide password' : 'Show password'}
          onClick={() => setVisible((v) => !v)}
          className="absolute inset-y-0 right-2 flex items-center px-2 text-sm text-muted-foreground"
        >
          {visible ? <EyeOffIcon className="h-5 w-5" /> : <EyeIcon className="h-5 w-5" />}
        </button>
      )}
    </div>
  );
}
