interface Props {
  className?: string;
  width?: number;
  height?: number;
  rounded?: string;
}

export default function Shimmer({
  className = '',
  width,
  height,
  rounded = "md",
}: Props) {
  const widthStr = !width ? "full" : `[${width}px]`;
  const heightStr = !height ? "full" : `[${height}px]`;

  return (
    <div
      className={`animate-pulse bg-gray-200 w-${widthStr} h-${heightStr} rounded-${rounded} ${className}`.trim()}
    ></div>
  );
}
