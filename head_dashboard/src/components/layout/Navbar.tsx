
import React from 'react';
import { 
  Bell, 
  Search, 
  User,
  LogOut
} from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';

const Navbar: React.FC = () => {
  const navigate = useNavigate();
  const [showLogoutDialog, setShowLogoutDialog] = React.useState(false);
  const [showProfileDropdown, setShowProfileDropdown] = React.useState(false);

  const handleLogout = () => {
    // Clear authentication state and token
    localStorage.removeItem('isAuthenticated');
    localStorage.removeItem('authToken');
    document.cookie = 'authToken=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT';
    navigate('/login');
  };

  return (
    <>
      <div className="h-16 border-b border-border flex items-center justify-between px-6 bg-background/95 backdrop-blur-sm sticky top-0 z-10">
        <div className="flex items-center">
          <div className="relative rounded-md w-64">
            <div className="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
              <Search className="h-4 w-4 text-muted-foreground" />
            </div>
            <input
              type="text"
              className="block w-full rounded-md border-0 py-1.5 pl-10 text-sm text-foreground bg-muted input-focus"
              placeholder="Search..."
            />
          </div>
        </div>
        
        <div className="flex items-center space-x-4">
          <button className="w-8 h-8 rounded-full flex items-center justify-center hover:bg-muted transition-colors relative">
            <Bell size={18} className="text-muted-foreground" />
            <span className="absolute top-0 right-0 w-2 h-2 bg-anganwadi-severe rounded-full"></span>
          </button>
          
          <div className="relative">
            <button
              onClick={() => setShowProfileDropdown(!showProfileDropdown)}
              className="flex items-center space-x-2 hover:bg-muted p-2 rounded-lg transition-colors"
            >
              <div className="w-8 h-8 rounded-full bg-muted flex items-center justify-center overflow-hidden">
                <img
                  src="/placeholder.svg"
                  alt="Profile"
                  className="w-full h-full object-cover"
                  onError={(e) => {
                    e.currentTarget.src = '/placeholder.svg';
                  }}
                />
              </div>
              <div className="hidden md:block">
                <div className="text-sm font-medium">Admin User</div>
                <div className="text-xs text-muted-foreground">Supervisor</div>
              </div>
            </button>

            {showProfileDropdown && (
              <div className="absolute right-0 mt-2 w-64 bg-card rounded-lg shadow-lg border border-border py-2 z-50">
                <div className="px-4 py-3 border-b border-border">
                  <div className="flex items-center space-x-3">
                    <div className="w-12 h-12 rounded-full bg-muted flex items-center justify-center overflow-hidden">
                      <img
                        src="/placeholder.svg"
                        alt="Profile"
                        className="w-full h-full object-cover"
                        onError={(e) => {
                          e.currentTarget.src = '/placeholder.svg';
                        }}
                      />
                    </div>
                    <div>
                      <div className="font-medium">Admin User</div>
                      <div className="text-sm text-muted-foreground">admin@example.com</div>
                    </div>
                  </div>
                </div>
                <div className="py-1">
                  <button
                    onClick={() => setShowLogoutDialog(true)}
                    className="w-full px-4 py-2 text-sm text-left hover:bg-muted transition-colors flex items-center space-x-2"
                  >
                    <LogOut size={16} />
                    <span>Logout</span>
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      <Dialog open={showLogoutDialog} onOpenChange={setShowLogoutDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Confirm Logout</DialogTitle>
            <DialogDescription>
              Are you sure you want to logout? You'll need to login again to access the dashboard.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowLogoutDialog(false)}>
              Cancel
            </Button>
            <Button variant="destructive" onClick={handleLogout}>
              Logout
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </>
  );
};

export default Navbar;
