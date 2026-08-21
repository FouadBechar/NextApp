import React from 'react';
import { EyeIcon as HeroEyeIcon } from '@heroicons/react/24/outline';

type Props = React.SVGProps<SVGSVGElement> & { className?: string };

export default function EyeIcon(props: Props) {
  return <HeroEyeIcon aria-hidden="true" {...props} />;
}
