'use client';

const Header = ({ name }) => {
  
  const now = new Date();
  const dateStr = now.toLocaleDateString('en-US', { 
    weekday: 'long', 
    year: 'numeric', 
    month: 'long', 
    day: 'numeric' 
  });
  const timeStr = now.toLocaleTimeString('en-US', { 
    hour: '2-digit', 
    minute: '2-digit' 
  });

  return (
    <header className="flex flex-col md:flex-row justify-between items-start md:items-center mb-6">
      <div>
        <h1 className="text-2xl md:text-3xl font-bold">{name} Dashboard</h1>
        <p className="text-gray-600">Manage your restaurant operations</p>
      </div>
      <div className="mt-2 md:mt-0 text-right">
        <p className="font-medium">{dateStr}</p>
        <p className="text-gray-600">{timeStr}</p>
      </div>
    </header>
  );
};

export default Header;