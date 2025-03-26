import React, { useState } from 'react';
import { MapPin, User } from 'lucide-react';
import CenterDetailsModal from './CenterDetailsModal';

export interface Center {
  center_name: string;
  state: string;
  full_name: string;
  status: string;
  email?: string;
  phone_number?: string;
  village?: string;
  district?: string;
  pin_code?: string;
}

interface CenterTableProps {
  centers: Center[];
}

const CenterTable: React.FC<CenterTableProps> = ({ centers }) => {
  const [selectedCenter, setSelectedCenter] = useState<Center | null>(null);
  const [isDetailsModalOpen, setIsDetailsModalOpen] = useState(false);

  const handleCenterClick = (center: Center) => {
    setSelectedCenter(center);
    setIsDetailsModalOpen(true);
  };

  return (
    <div className="bg-card rounded-lg border shadow-sm overflow-hidden">
      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead className="bg-muted text-muted-foreground text-left">
            <tr>
              <th className="px-4 py-3 font-medium">Center Name</th>
              <th className="px-4 py-3 font-medium">State</th>
              <th className="px-4 py-3 font-medium">Supervisor</th>
              <th className="px-4 py-3 font-medium">Status</th>
            </tr>
          </thead>
          <tbody className="divide-y">
            {centers.map((center, index) => (
              <tr key={index} className="hover:bg-muted/50 transition-colors">
                <td 
                  className="px-4 py-3 font-medium cursor-pointer hover:text-primary"
                  onClick={() => handleCenterClick(center)}
                >
                  {center.center_name}
                </td>
                <td className="px-4 py-3 text-muted-foreground">
                  <div className="flex items-center">
                    <MapPin size={14} className="mr-1 text-muted-foreground" />
                    {center.state}
                  </div>
                </td>
                <td className="px-4 py-3 text-muted-foreground">
                  <div className="flex items-center">
                    <User size={14} className="mr-1 text-muted-foreground" />
                    {center.full_name}
                  </div>
                </td>
                <td className="px-4 py-3">{center.status}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <CenterDetailsModal
        isOpen={isDetailsModalOpen}
        onClose={() => setIsDetailsModalOpen(false)}
        centerDetails={selectedCenter}
      />
    </div>
  );
};

export default CenterTable;
