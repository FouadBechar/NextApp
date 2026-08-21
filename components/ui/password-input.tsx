"use client";

import React, { useState } from 'react';
import EyeIcon from '@/components/icons/eye';
import EyeOffIcon from '@/components/icons/eye-off';
import { cn } from '@/lib/utils';

type Props = React.InputHTMLAttributes<HTMLInputElement> & {
  inputRef?: React.Ref<HTMLInputElement>;
  showToggle?: boolean;
};

export default function PasswordInput({ inputRef, showToggle = true, className, ...props }: Props) {
  const [visible, setVisible] = useState(false);

  const inputClasses = cn(
    "border-input file:text-foreground placeholder:text-muted-foreground selection:bg-primary selection:text-primary-foreground flex h-9 w-full min-w-0 rounded-md border bg-transparent px-3 py-1 text-base shadow-xs transition-[color,box-shadow] outline-none file:inline-flex file:h-7 file:border-0 file:bg-transparent file:text-sm file:font-medium disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50 md:text-sm",
    "focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]",
    "aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive",
    'pr-9',
    className
  );

  return (
    <div className="relative">
      <input
        ref={inputRef}
        data-slot="input"
        {...props}
        type={visible ? 'text' : 'password'}
        className={inputClasses}
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
