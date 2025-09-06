"use client";
import { useAuth } from "@/hooks/useAuth";
import Link from "next/link";
import { usePathname } from "next/navigation";

const Sidebar = () => {
  const pathname = usePathname();

  const { logout } = useAuth();
  const isActive = (path) =>
    pathname === path || pathname.startsWith(path + "/");

  const menuItems = [
    { name: "Dashboard", icon: "📊", path: "/driver/dashboard" },
    { name: "Manage Orders", icon: "🚚", path: "/driver/manage-order" },
    { name: "Profile", icon: "👤", path: "/driver/profile" },
  ];

  return (
    <aside className="w-64 bg-white shadow-lg hidden md:block">
      <div className="p-4 border-b">
        <h2 className="text-lg font-bold text-gray-800">Driver Portal</h2>
      </div>

      <div className="p-4">
        <ul className="space-y-1">
          {menuItems.map((item) => (
            <li key={item.name}>
              <Link href={item.path} passHref>
                <div
                  className={`flex items-center p-3 rounded-lg transition cursor-pointer ${
                    isActive(item.path)
                      ? "bg-blue-100 text-blue-700 font-medium"
                      : "text-gray-700 hover:bg-gray-100"
                  }`}
                >
                  <span className="text-xl mr-3">{item.icon}</span>
                  <span>{item.name}</span>
                </div>
              </Link>
            </li>
          ))}
          <li className="mt-6">
            <button onClick={logout} className="bg-red-600 w-full rounded-lg p-3 text-white font-semibold text-lg cursor-pointer hover:bg-red-800 transition">
              Logout
            </button>
          </li>
        </ul>

        <div className="mt-6 p-3 bg-blue-50 rounded-lg">
          <h3 className="font-medium text-blue-800 mb-2">Driver Rating</h3>
          <div className="flex items-center">
            <div className="flex text-yellow-400">{"★".repeat(5)}</div>
            <span className="ml-2 text-sm">4.8/5.0</span>
          </div>
          <p className="mt-1 text-xs text-gray-600">98% positive feedback</p>
        </div>
      </div>
    </aside>
  );
};

export default Sidebar;
