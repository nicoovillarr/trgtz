export default function Input({ id, className, label, type, placeholder, value }: { id: string; className?: string; label: string; type: "password" | "text" | "email"; placeholder?: string; value?: string }) {
  return (
    <div className={className}>
      <label className="block text-sm font-medium">{label}</label>
      <input
        id={id}
        type={type}
        placeholder={placeholder}
        value={value}
        className="w-full p-2 border border-gray-300 bg-gray-100 rounded-sm outline-none"
      />
    </div>
  );
}