import React from 'react';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { MapPin, Mail, Phone, User, Building, MapPinned } from 'lucide-react';

interface CenterDetails {
  full_name: string;
  email: string;
  phone_number: string;
  center_name: string;
  village: string;
  district: string;
  state: string;
  pin_code: string;
}

interface CenterDetailsModalProps {
  isOpen: boolean;
  onClose: () => void;
  centerDetails: CenterDetails | null;
}

const CenterDetailsModal: React.FC<CenterDetailsModalProps> = ({ isOpen, onClose, centerDetails }) => {
  if (!centerDetails) return null;

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle className="text-xl font-semibold">{centerDetails.center_name}</DialogTitle>
        </DialogHeader>
        <div className="mt-4 space-y-4">
          {/* Supervisor Information */}
          <div className="space-y-2">
            <h3 className="text-sm font-medium text-muted-foreground">Supervisor Details</h3>
            <div className="flex items-center space-x-2">
              <User className="h-4 w-4 text-muted-foreground" />
              <span className="text-muted-foreground">Name:</span>
              <span>{centerDetails.full_name}</span>
            </div>
            <div className="flex items-center space-x-2">
              <Mail className="h-4 w-4 text-muted-foreground" />
              <span className="text-muted-foreground">Email:</span>
              <span>{centerDetails.email}</span>
            </div>
            <div className="flex items-center space-x-2">
              <Phone className="h-4 w-4 text-muted-foreground" />
              <span className="text-muted-foreground">Phone:</span>
              <span>{centerDetails.phone_number}</span>
            </div>
          </div>

          {/* Location Information */}
          <div className="space-y-2">
            <h3 className="text-sm font-medium text-muted-foreground">Location Details</h3>
            <div className="flex items-center space-x-2">
              <Building className="h-4 w-4 text-muted-foreground" />
              <span className="text-muted-foreground">Village:</span>
              <span>{centerDetails.village}</span>
            </div>
            <div className="flex items-center space-x-2">
              <MapPin className="h-4 w-4 text-muted-foreground" />
              <span className="text-muted-foreground">District:</span>
              <span>{centerDetails.district}</span>
            </div>
            <div className="flex items-center space-x-2">
              <MapPinned className="h-4 w-4 text-muted-foreground" />
              <span className="text-muted-foreground">State:</span>
              <span>{centerDetails.state}</span>
            </div>
            <div className="flex items-center space-x-2">
              <MapPin className="h-4 w-4 text-muted-foreground" />
              <span className="text-muted-foreground">PIN Code:</span>
              <span>{centerDetails.pin_code}</span>
            </div>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
};

export default CenterDetailsModal;