import React, { useState, useEffect } from 'react';
import DashboardCard from '@/components/dashboard/DashboardCard';
import {
  MapContainer,
  TileLayer,
  CircleMarker,
  Tooltip,
} from 'react-leaflet';
import 'leaflet/dist/leaflet.css';

export interface MapLocation {
  child_id: string;
  pin_code: string;
  village: string;
  district: string;
  severity: 'severe' | 'moderate';
  latitude?: number;
  longitude?: number;
}

interface NutritionMapProps {
  locations: MapLocation[];
}

type GeoLocation = Required<MapLocation>;

const NutritionMap: React.FC<NutritionMapProps> = ({ locations }) => {
  const [geoLocations, setGeoLocations] = useState<GeoLocation[]>([]);
  const [hoveredPinCode, setHoveredPinCode] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [mapBounds, setMapBounds] = useState<[[number, number], [number, number]] | null>(null);
  const [center, setCenter] = useState<[number, number]>([22.2587, 71.1924]); // Initial center

  const geocodePinCode = async (pin: string): Promise<[number, number] | null> => {
    try {
      const res = await fetch(
        `https://nominatim.openstreetmap.org/search?postalcode=${pin}&country=India&format=json`
      );
      const data = await res.json();
      if (data && data.length > 0) {
        return [parseFloat(data[0].lat), parseFloat(data[0].lon)];
      }
      return null;
    } catch (error) {
      console.error('Error fetching geocode:', error);
      return null;
    }
  };

  useEffect(() => {
    const fetchAllLocations = async () => {
      setIsLoading(true);
      const uniqueLocations = new Map<string, MapLocation>();
      
      // Group locations by pin code to avoid duplicates
      locations.forEach(loc => {
        const key = `${loc.pin_code}`;
        if (!uniqueLocations.has(key)) {
          uniqueLocations.set(key, loc);
        }
      });

      const geoLocationsArray: GeoLocation[] = [];
      
      for (const loc of uniqueLocations.values()) {
        if (loc.latitude && loc.longitude) {
          geoLocationsArray.push(loc as GeoLocation);
          continue;
        }

        const coords = await geocodePinCode(loc.pin_code);
        if (coords) {
          geoLocationsArray.push({
            ...loc,
            latitude: coords[0],
            longitude: coords[1],
          });
        }
        await new Promise(resolve => setTimeout(resolve, 1000)); // Respect Nominatim rate limit
      }

      if (geoLocationsArray.length > 0) {
        const lats = geoLocationsArray.map(loc => loc.latitude);
        const lngs = geoLocationsArray.map(loc => loc.longitude);
        const minLat = Math.min(...lats);
        const maxLat = Math.max(...lats);
        const minLng = Math.min(...lngs);
        const maxLng = Math.max(...lngs);
        
        setMapBounds([[minLat, minLng], [maxLat, maxLng]]);
        setCenter([(minLat + maxLat) / 2, (minLng + maxLng) / 2]);
      }
      
      setGeoLocations(geoLocationsArray);
      setIsLoading(false);
    };

    if (locations.length) {
      fetchAllLocations();
    }
  }, [locations]);

  const getSeverityColor = (severity: 'severe' | 'moderate') => {
    return severity === 'severe'
      ? { color: '#dc2626', weight: 2 }
      : { color: '#2563eb', weight: 1.5 };
  };

  return (
    <DashboardCard title="Nutrition Hotspots" subtitle="Geographical distribution">
      <div className="flex flex-col space-y-4">
        <div className="h-80 rounded-lg overflow-hidden border relative">
          {isLoading ? (
            <div className="flex items-center justify-center h-full text-muted-foreground">
              Loading map data...
            </div>
          ) : (
            <MapContainer
              center={center}
              bounds={mapBounds || undefined}
              zoom={mapBounds ? undefined : 7}
              style={{ height: '100%', width: '100%' }}
              scrollWheelZoom={false}
            >
              <TileLayer
                attributionControl={true}
                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
              />

              {geoLocations.map((location, index) => {
                const isHovered = hoveredPinCode === location.pin_code;
                const radius = isHovered ? 18 : 15;
                const { color, weight } = getSeverityColor(location.severity);

                return (
                  <CircleMarker
                    key={`${location.pin_code}-${location.child_id}-${index}`} // FIX: Ensure unique key
                    center={[location.latitude, location.longitude]}
                    radius={radius}
                    fillColor={color}
                    color={color}
                    weight={weight}
                    opacity={1}
                    fillOpacity={0.6}
                    eventHandlers={{
                      mouseover: () => setHoveredPinCode(location.pin_code),
                      mouseout: () => setHoveredPinCode(null),
                    }}
                  >
                    <Tooltip permanent={isHovered}>
                      <div className="text-sm">
                        <p className="font-medium">
                          Location: {location.village}
                        </p>
                        <p className="text-xs text-muted-foreground">
                          District: {location.district}
                        </p>
                        <p
                          className={
                            location.severity === 'severe'
                              ? 'text-anganwadi-severe'
                              : 'text-anganwadi-moderate'
                          }
                        >
                          {location.severity.charAt(0).toUpperCase() +
                            location.severity.slice(1)}{' '}
                          Case
                        </p>
                        <p className="text-xs text-muted-foreground">
                          PIN: {location.pin_code}
                        </p>
                      </div>
                    </Tooltip>
                  </CircleMarker>
                );
              })}
            </MapContainer>
          )}

          <div className="absolute bottom-3 right-3 bg-card rounded-md shadow-md p-2 text-xs z-[1000]">
            <div className="flex items-center mb-1">
              <span className="inline-block w-3 h-3 rounded-full bg-anganwadi-severe mr-1"></span>
              <span>Severe Cases</span>
            </div>
            <div className="flex items-center">
              <span className="inline-block w-3 h-3 rounded-full bg-anganwadi-moderate mr-1"></span>
              <span>Moderate Cases</span>
            </div>
          </div>
        </div>

        <div className="bg-card rounded-lg border shadow-sm overflow-hidden">
          <table className="w-full text-sm">
            <thead className="bg-muted text-muted-foreground text-left">
              <tr>
                <th className="px-4 py-3 font-medium">Location</th>
                <th className="px-4 py-3 font-medium">PIN Code</th>
                <th className="px-4 py-3 font-medium">Severity</th>
              </tr>
            </thead>
            <tbody className="divide-y">
              {geoLocations.map((location, index) => (
                <tr
                  key={`row-${location.pin_code}-${location.child_id}-${index}`} // FIX: Ensure unique key
                  className="hover:bg-muted/50 transition-colors cursor-pointer"
                  onMouseEnter={() => setHoveredPinCode(location.pin_code)}
                  onMouseLeave={() => setHoveredPinCode(null)}
                >
                  <td className="px-4 py-3">
                    {location.village}, {location.district}
                  </td>
                  <td className="px-4 py-3 text-muted-foreground">
                    {location.pin_code}
                  </td>
                  <td className="px-4 py-3">
                    <span
                      className={`${
                        location.severity === 'severe'
                          ? 'bg-anganwadi-severe/10 text-anganwadi-severe'
                          : 'bg-anganwadi-moderate/10 text-anganwadi-moderate'
                      } text-xs px-2 py-1 rounded-full`}
                    >
                      {location.severity.charAt(0).toUpperCase() +
                        location.severity.slice(1)}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </DashboardCard>
  );
};

export default NutritionMap;
