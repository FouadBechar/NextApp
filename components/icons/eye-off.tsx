import React from 'react';
import { EyeSlashIcon as HeroEyeSlashIcon } from '@heroicons/react/24/outline';

type Props = React.SVGProps<SVGSVGElement> & { className?: string };

export default function EyeOffIcon(props: Props) {
  return <HeroEyeSlashIcon aria-hidden="true" {...props} />;
}
