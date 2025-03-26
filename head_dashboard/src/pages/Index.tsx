
// Import the correct MapLocation type
import { MapLocation } from '@/components/dashboard/NutritionMap';
import Layout from "@/components/layout/Layout";
import PageTitle from "@/components/common/PageTitle";
import DashboardCard from "@/components/dashboard/DashboardCard";
import { Button } from "@/components/ui/button";
import { Plus as PlusIcon } from "lucide-react"; // Changed from @radix-ui/react-icons to lucide-react
import { Calendar } from "@/components/ui/calendar";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { cn } from "@/lib/utils";
import { addDays, format } from "date-fns";
import { CalendarIcon } from "lucide-react";
import { useState } from "react";
import { Progress } from "@/components/ui/progress";
import NutritionMap from "@/components/dashboard/NutritionMap";

const Index = () => {
  const [date, setDate] = useState<Date | undefined>(new Date());

  // Update the hotspots data to use the correct severity type
  const hotspots: MapLocation[] = [
    { id: 1, name: 'North District', severity: 'severe', x: 25, y: 35, count: 32 },
    { id: 2, name: 'East Village', severity: 'moderate', x: 65, y: 45, count: 18 },
    { id: 3, name: 'South Center', severity: 'mild', x: 40, y: 70, count: 12 },
    { id: 4, name: 'West Region', severity: 'healthy', x: 15, y: 60, count: 5 },
    { id: 5, name: 'Central Area', severity: 'moderate', x: 50, y: 50, count: 22 }
  ];

  return (
    <Layout>
      <PageTitle title="Dashboard" subtitle="Overview of key metrics and insights">
      </PageTitle>

      <div className="grid gap-4 grid-cols-1 md:grid-cols-2 lg:grid-cols-4">
        <DashboardCard title="Total Children" subtitle="As of today">
          <div className="text-3xl font-bold">1,250</div>
        </DashboardCard>

        <DashboardCard title="Severely Malnourished" subtitle="Children needing immediate attention">
          <div className="text-3xl font-bold text-anganwadi-severe">150</div>
        </DashboardCard>

        <DashboardCard title="Moderate Cases" subtitle="Children requiring close monitoring">
          <div className="text-3xl font-bold text-anganwadi-moderate">320</div>
        </DashboardCard>

        <DashboardCard title="Healthy Children" subtitle="Children with normal nutrition levels">
          <div className="text-3xl font-bold text-anganwadi-healthy">780</div>
        </DashboardCard>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4 mt-6">
        <DashboardCard title="Upcoming Health Checkups" subtitle="Scheduled for this week">
          <div className="flex items-center justify-between mb-4">
            <span>John Doe</span>
            <Popover>
              <PopoverTrigger asChild>
                <Button
                  variant={"ghost"}
                  className={cn(
                    "pl-3 text-left font-normal",
                    !date && "text-muted-foreground"
                  )}
                >
                  {date ? format(date, "PPP") : (
                    <span>Pick a date</span>
                  )}
                  <CalendarIcon className="ml-2 h-4 w-4 opacity-50" />
                </Button>
              </PopoverTrigger>
              <PopoverContent className="w-auto p-0" align="start" side="bottom">
                <Calendar
                  mode="single"
                  selected={date}
                  onSelect={setDate}
                  disabled={(date) =>
                    date > addDays(new Date(), 30) || date < new Date()
                  }
                  initialFocus
                />
              </PopoverContent>
            </Popover>
          </div>
          <div className="flex items-center justify-between mb-4">
            <span>Jane Smith</span>
            <Popover>
              <PopoverTrigger asChild>
                <Button
                  variant={"ghost"}
                  className={cn(
                    "pl-3 text-left font-normal",
                    !date && "text-muted-foreground"
                  )}
                >
                  {date ? format(date, "PPP") : (
                    <span>Pick a date</span>
                  )}
                  <CalendarIcon className="ml-2 h-4 w-4 opacity-50" />
                </Button>
              </PopoverTrigger>
              <PopoverContent className="w-auto p-0" align="start" side="bottom">
                <Calendar
                  mode="single"
                  selected={date}
                  onSelect={setDate}
                  disabled={(date) =>
                    date > addDays(new Date(), 30) || date < new Date()
                  }
                  initialFocus
                />
              </PopoverContent>
            </Popover>
          </div>
          <div className="flex items-center justify-between mb-4">
            <span>Alice Johnson</span>
            <Popover>
              <PopoverTrigger asChild>
                <Button
                  variant={"ghost"}
                  className={cn(
                    "pl-3 text-left font-normal",
                    !date && "text-muted-foreground"
                  )}
                >
                  {date ? format(date, "PPP") : (
                    <span>Pick a date</span>
                  )}
                  <CalendarIcon className="ml-2 h-4 w-4 opacity-50" />
                </Button>
              </PopoverTrigger>
              <PopoverContent className="w-auto p-0" align="start" side="bottom">
                <Calendar
                  mode="single"
                  selected={date}
                  onSelect={setDate}
                  disabled={(date) =>
                    date > addDays(new Date(), 30) || date < new Date()
                  }
                  initialFocus
                />
              </PopoverContent>
            </Popover>
          </div>
        </DashboardCard>

        <DashboardCard title="Nutrition Levels Overview" subtitle="Current progress across all children">
          <div className="space-y-3">
            <div className="space-y-1">
              <p className="text-sm font-medium">Severe</p>
              <Progress value={15} color="bg-anganwadi-severe" />
            </div>
            <div className="space-y-1">
              <p className="text-sm font-medium">Moderate</p>
              <Progress value={32} color="bg-anganwadi-moderate" />
            </div>
            <div className="space-y-1">
              <p className="text-sm font-medium">Mild</p>
              <Progress value={23} color="bg-anganwadi-mild" />
            </div>
            <div className="space-y-1">
              <p className="text-sm font-medium">Healthy</p>
              <Progress value={78} color="bg-anganwadi-healthy" />
            </div>
          </div>
        </DashboardCard>

        <NutritionMap locations={hotspots} />
      </div>
    </Layout>
  );
};

export default Index;
