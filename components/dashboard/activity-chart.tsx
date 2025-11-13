"use client";

import React, { useMemo, useRef, useState, useCallback } from "react";

type Props = {
  counts: number[];
  labels?: string[] | null;
  height?: number;
  showDotsInterval?: number; // show dots every N points for readability
};

// Helper: Catmull-Rom to Cubic Bezier conversion for smoothing
function catmullRom2bezier(points: { x: number; y: number }[]) {
  if (points.length < 2) return "";
  const d = [] as string[];
  for (let i = 0; i < points.length; i++) {
    const p0 = points[i - 1] || points[i];
    const p1 = points[i];
    const p2 = points[i + 1] || p1;
    const p3 = points[i + 2] || p2;

    if (i === 0) {
      d.push(`M${p1.x},${p1.y}`);
    }

    // tension of 0.5 gives a smooth curve
    const t = 0.5;
    const cp1x = p1.x + (p2.x - p0.x) / 6 * t * 2;
    const cp1y = p1.y + (p2.y - p0.y) / 6 * t * 2;
    const cp2x = p2.x - (p3.x - p1.x) / 6 * t * 2;
    const cp2y = p2.y - (p3.y - p1.y) / 6 * t * 2;

    d.push(`C${cp1x},${cp1y} ${cp2x},${cp2y} ${p2.x},${p2.y}`);
  }
  return d.join(" ");
}

export default function ActivityChart({ counts, labels = null, height = 120, showDotsInterval = 5 }: Props) {
  const svgRef = useRef<SVGSVGElement | null>(null);
  const [hoverIndex, setHoverIndex] = useState<number | null>(null);
  const [tooltip, setTooltip] = useState<{ x: number; y: number; label?: string; value?: number } | null>(null);

  const memo = useMemo(() => {
    const days = counts.length;
    const w = 600;
    const h = height;
    const paddingX = 8;
    const paddingY = 12;

    const max = Math.max(1, ...counts);
    const step = (w - paddingX * 2) / Math.max(1, days - 1);

    const points = counts.map((c, i) => {
      const x = paddingX + i * step;
      const y = paddingY + (1 - c / max) * (h - paddingY * 2);
      return { x, y, v: c };
    });

    const smoothPath = catmullRom2bezier(points.map((p) => ({ x: p.x, y: p.y })));
    const areaPath = `${smoothPath} L ${points[points.length - 1].x},${h - paddingY} L ${points[0].x},${h - paddingY} Z`;

    const dots = points.filter((_, i) => i === points.length - 1 || (i % showDotsInterval === 0));

    return { w, h, points, smoothPath, areaPath, dots };
  }, [counts, height, showDotsInterval]);

  const onPointerMove = useCallback(
    (e: React.PointerEvent) => {
      const svg = svgRef.current;
      if (!svg) return;
      const rect = svg.getBoundingClientRect();
      const x = ((e.clientX - rect.left) / rect.width) * memo.w;

      // find nearest point by x
      let nearest = 0;
      let bestDx = Infinity;
      for (let i = 0; i < memo.points.length; i++) {
        const dx = Math.abs(memo.points[i].x - x);
        if (dx < bestDx) {
          bestDx = dx;
          nearest = i;
        }
      }
      const p = memo.points[nearest];
      setHoverIndex(nearest);
      const tooltipX = (p.x / memo.w) * rect.width + rect.left;
      const tooltipY = (p.y / memo.h) * rect.height + rect.top;
      setTooltip({ x: tooltipX, y: tooltipY, label: labels?.[nearest], value: p.v });
    },
    [memo, labels]
  );

  const onPointerLeave = useCallback(() => {
    setHoverIndex(null);
    setTooltip(null);
  }, []);

  if (!counts || counts.length === 0) return null;

  return (
    <div className="w-full relative" role="img" aria-label="Activity chart">
      <svg
        ref={svgRef}
        viewBox={`0 0 ${memo.w} ${memo.h}`}
        preserveAspectRatio="none"
        className="w-full h-auto"
        height={memo.h}
        onPointerMove={onPointerMove}
        onPointerLeave={onPointerLeave}
      >
        <defs>
          <linearGradient id="acGrad" x1="0" x2="0" y1="0" y2="1">
            <stop offset="0%" stopColor="#3b82f6" stopOpacity="0.18" />
            <stop offset="100%" stopColor="#3b82f6" stopOpacity="0" />
          </linearGradient>
        </defs>

        <path d={memo.areaPath} fill="url(#acGrad)" stroke="none" />
        <path d={memo.smoothPath} fill="none" stroke="#2563eb" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />

        {memo.dots.map((d, i) => (
          <circle key={i} cx={d.x} cy={d.y} r={2.5} fill="#2563eb" stroke="#fff" strokeWidth={1} />
        ))}

        {hoverIndex !== null && (
          <g>
            <line
              x1={memo.points[hoverIndex].x}
              x2={memo.points[hoverIndex].x}
              y1={0}
              y2={memo.h}
              stroke="#c7d2fe"
              strokeWidth={1}
              strokeDasharray="4 3"
            />
            <circle cx={memo.points[hoverIndex].x} cy={memo.points[hoverIndex].y} r={4} fill="#fff" stroke="#2563eb" strokeWidth={2} />
          </g>
        )}
      </svg>

      {tooltip && (
        <div className="pointer-events-none absolute z-10 bg-white border rounded px-2 py-1 text-xs shadow-md left-1/2 -translate-x-1/2 top-2">
          <div className="font-medium">{tooltip.value}</div>
          {tooltip.label && <div className="text-muted-foreground">{tooltip.label}</div>}
        </div>
      )}
    </div>
  );
}
