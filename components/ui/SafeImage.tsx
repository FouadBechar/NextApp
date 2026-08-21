"use client";
import React from 'react';

type Props = React.ImgHTMLAttributes<HTMLImageElement> & {
  src?: string | null;
};

export default function SafeImage({ src, alt = '', className, ...rest }: Props) {
  const safe = src && String(src).trim() !== '' ? String(src) : undefined;
  if (!safe) return null;
  // eslint-disable-next-line @next/next/no-img-element
  return <img src={safe} alt={alt} className={className} {...rest} />;
}
