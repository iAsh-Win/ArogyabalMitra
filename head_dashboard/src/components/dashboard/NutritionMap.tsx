
import React, { useState } from 'react';
import DashboardCard from './DashboardCard';

export interface MapLocation {
  id: number;
  name: string;
  severity: 'severe' | 'moderate' | 'mild' | 'healthy';
  x: number;
  y: number;
  count: number;
}

interface NutritionMapProps {
  locations: MapLocation[];
}

const NutritionMap: React.FC<NutritionMapProps> = ({ locations }) => {
  const [activeLocation, setActiveLocation] = useState<MapLocation | null>(null);
  
  const getSeverityColor = (severity: 'severe' | 'moderate' | 'mild' | 'healthy') => {
    switch (severity) {
      case 'severe':
        return 'bg-anganwadi-severe';
      case 'moderate':
        return 'bg-anganwadi-moderate';
      case 'mild':
        return 'bg-anganwadi-mild';
      case 'healthy':
        return 'bg-anganwadi-healthy';
      default:
        return 'bg-gray-400';
    }
  };
  
  const getSeveritySize = (count: number) => {
    // Scale the size based on count
    const baseSize = 10;
    const maxSize = 24;
    const scale = Math.min(count / 20, 1); // Normalize to max 1
    return baseSize + (maxSize - baseSize) * scale;
  };

  return (
    <DashboardCard title="Nutrition Hotspots" subtitle="Geographical distribution">
      <div className="relative h-80 bg-anganwadi-secondary rounded-lg overflow-hidden">
        {/* This would be replaced with an actual map component */}
        <div className="absolute inset-0 bg-[url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNjAiIGhlaWdodD0iNjAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PGRlZnM+PHBhdHRlcm4gaWQ9ImdyaWQiIHdpZHRoPSI2MCIgaGVpZ2h0PSI2MCIgcGF0dGVyblVuaXRzPSJ1c2VyU3BhY2VPblVzZSI+PHBhdGggZD0iTSAwIDYwIEwgNjAgNjAiIHN0cm9rZT0iIzBFQTVFOTEwIiBzdHJva2Utd2lkdGg9IjAuNSIvPjxwYXRoIGQ9Ik0gNjAgMCBMIDYwIDYwIiBzdHJva2U9IiMwRUE1RTkxMCIgc3Ryb2tlLXdpZHRoPSIwLjUiLz48L3BhdHRlcm4+PC9kZWZzPjxyZWN0IHdpZHRoPSIxMDAlIiBoZWlnaHQ9IjEwMCUiIGZpbGw9InVybCgjZ3JpZCkiLz48L3N2Zz4=')] opacity-50"></div>
        
        {locations.map((location) => {
          const size = getSeveritySize(location.count);
          const isActive = activeLocation?.id === location.id;
          
          return (
            <div 
              key={location.id}
              className={`absolute rounded-full cursor-pointer transition-all duration-300 transform ${isActive ? 'scale-150 z-20' : 'z-10'}`}
              style={{ 
                left: `${location.x}%`, 
                top: `${location.y}%`, 
                width: `${size}px`, 
                height: `${size}px`,
                marginLeft: `-${size/2}px`,
                marginTop: `-${size/2}px`
              }}
              onMouseEnter={() => setActiveLocation(location)}
              onMouseLeave={() => setActiveLocation(null)}
            >
              <div 
                className={`w-full h-full rounded-full ${getSeverityColor(location.severity)} animate-pulse-slow`}
              />
              {isActive && (
                <div className="absolute left-1/2 bottom-full mb-2 transform -translate-x-1/2 bg-card rounded-md shadow-lg py-1 px-2 text-xs whitespace-nowrap border">
                  <p className="font-medium">{location.name}</p>
                  <p><span className={`inline-block w-2 h-2 rounded-full ${getSeverityColor(location.severity)} mr-1`}></span> {location.count} cases</p>
                </div>
              )}
            </div>
          );
        })}
        
        <div className="absolute bottom-3 right-3 bg-card rounded-md shadow-md p-2 text-xs">
          <div className="flex items-center mb-1">
            <span className="inline-block w-3 h-3 rounded-full bg-anganwadi-severe mr-1"></span>
            <span>Severe</span>
          </div>
          <div className="flex items-center mb-1">
            <span className="inline-block w-3 h-3 rounded-full bg-anganwadi-moderate mr-1"></span>
            <span>Moderate</span>
          </div>
          <div className="flex items-center mb-1">
            <span className="inline-block w-3 h-3 rounded-full bg-anganwadi-mild mr-1"></span>
            <span>Mild</span>
          </div>
          <div className="flex items-center">
            <span className="inline-block w-3 h-3 rounded-full bg-anganwadi-healthy mr-1"></span>
            <span>Healthy</span>
          </div>
        </div>
      </div>
    </DashboardCard>
  );
};

export default NutritionMap;
