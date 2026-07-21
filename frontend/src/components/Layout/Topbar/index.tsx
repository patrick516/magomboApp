export function Topbar({ title }: { title: string }) {
  return (
    <header className="h-16 bg-white border-b flex items-center px-8 sticky top-0 z-10">
      <h2 className="text-xl font-semibold text-foreground">{title}</h2>
    </header>
  );
}
