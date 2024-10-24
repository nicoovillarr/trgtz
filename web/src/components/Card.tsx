interface Props {
  horizontalAlign?: "left" | "center" | "right";
  verticalAlign?: "top" | "center" | "bottom";
  children?: React.ReactNode;
}

export default function Card({
  horizontalAlign = "center",
  verticalAlign = "center",
  children,
}: Props) {
  const horizontalAlignClass =
    horizontalAlign === "left"
      ? "justify-start"
      : horizontalAlign === "center"
      ? "justify-center"
      : "justify-end";

  const verticalAlignClass =
    verticalAlign === "top"
      ? "items-start"
      : verticalAlign === "center"
      ? "items-center"
      : "items-end";

  return (
    <article
      className={`flex flex-col ${horizontalAlignClass} ${verticalAlignClass} bg-white rounded-md shadow-md p-8`}
    >
      {children}
    </article>
  );
}
