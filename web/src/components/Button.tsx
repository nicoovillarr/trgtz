interface Props {
  link?: string;
  newTab?: boolean;
  type?: "special" | "primary" | "secondary" | "tertiary";
  outlined?: boolean;
  onClick?: () => void;
  children?: React.ReactNode;
  disabled?: boolean;
}

export default function Button({
  link = "",
  newTab = true,
  type = "primary",
  outlined = true,
  onClick,
  children,
  disabled = false,
}: Props) {
  const classes = {
    special:
      "bg-gradient-to-tr from-primary to-pinky px-6 py-1 rounded-full text-white hover:scale-105",
    primary:
      "bg-primary text-white border-primary rounded-sm hover:bg-primary-light hover:border-primary-light",
    secondary:
      "bg-gray-200 text-gray-800 border-gray-200 rounded-sm hover:bg-gray-300 hover:border-gray-300",
    tertiary: `bg-transparent text-primary rounded-sm hover:bg-gray-100 ${
      outlined ? "border-primary" : "border-transparent"
    }`,
  };

  const styles = `flex items-center gap-x-2 px-4 py-2 text-sm border transition-all ${classes[type]} disabled:opacity-50 disabled:pointer-events-none`;
  const isLink = !!link && link != "";

  if (!isLink) {
    return (
      <button
        className={styles}
        type="button"
        onClick={onClick}
        disabled={disabled}
      >
        {children}
      </button>
    );
  } else {
    return (
      <a
        href={link}
        target={newTab ? "_blank" : "_self"}
        referrerPolicy="no-referrer"
        className={styles}
      >
        {children}
      </a>
    );
  }
}
