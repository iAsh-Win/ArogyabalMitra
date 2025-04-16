
import React from 'react';
import { User } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

const ChildrenTable = ({ children = [] }) => {
  const navigate = useNavigate();
  
  if (!Array.isArray(children)) {
    console.error('Children prop must be an array');
    return null;
  }

  const handleRowClick = (child) => {
    navigate(`/children/child/${child.id}`);
  };

  const getNutritionalStatusBadge = (status) => {
    if (!status) return <span className="bg-gray-100 text-gray-600 text-xs px-2 py-1 rounded-full">New Registered Child</span>;
    
    switch (status.toLowerCase()) {
      case 'no malnutrition':
        return <span className="bg-anganwadi-healthy/10 text-anganwadi-healthy text-xs px-2 py-1 rounded-full">No Malnutrition</span>;
      case 'severe malnutrition':
        return <span className="bg-anganwadi-severe/10 text-anganwadi-severe text-xs px-2 py-1 rounded-full">Severe</span>;
      case 'moderate malnutrition':
        return <span className="bg-anganwadi-moderate/10 text-anganwadi-moderate text-xs px-2 py-1 rounded-full">Moderate</span>;
      default:
        return <span className="bg-gray-100 text-gray-600 text-xs px-2 py-1 rounded-full">New Registered Child</span>;
    }
  };

  return (
    <div className="bg-card rounded-lg border shadow-sm overflow-hidden">
      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead className="bg-muted text-muted-foreground text-left">
            <tr>
              <th className="px-4 py-3 font-medium">Name</th>
              <th className="px-4 py-3 font-medium">Age</th>
              <th className="px-4 py-3 font-medium">Center</th>
              <th className="px-4 py-3 font-medium">Nutritional Status</th>
            </tr>
          </thead>
          <tbody className="divide-y">
            {children.map((child, index) => (
              <tr 
                key={index} 
                className="hover:bg-muted/50 transition-colors cursor-pointer"
                onClick={() => handleRowClick(child)}
              >
                <td className="px-4 py-3 font-medium">{child.name}</td>
                <td className="px-4 py-3 text-muted-foreground">
                  <div className="flex items-center">
                    <User size={14} className="mr-1 text-muted-foreground" />
                    {child.age.years} yrs {child.age.months} months
                  </div>
                </td>
                <td className="px-4 py-3 text-muted-foreground">{child.center.name}, {child.center.village}</td>
                <td className="px-4 py-3">{getNutritionalStatusBadge(child.malnutrition_status)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default ChildrenTable;
