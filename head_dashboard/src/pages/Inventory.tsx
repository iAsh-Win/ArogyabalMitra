import React, { useState } from 'react';
import Layout from '@/components/layout/Layout';
import PageTitle from '@/components/common/PageTitle';
import DashboardCard from '@/components/dashboard/DashboardCard';
import { Package, AlertCircle, Truck, ShoppingBag, Clock } from 'lucide-react';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Button } from '@/components/ui/button';
import { useToast } from '@/hooks/use-toast';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Card } from '@/components/ui/card';

// Mock data
const supplements = [
  {
    id: 1,
    name: 'Protein Supplement',
    totalStock: 2450,
    allocated: 1850,
    remaining: 600,
    threshold: 500,
    required: 2000,
    stockPercentage: 30,
    status: 'low',
    center: 'Regional Warehouse A',
    projectedDepleteDate: '2023-10-15',
    lastUpdated: 'Aug 10, 2023'
  },
  {
    id: 2,
    name: 'Iron Tablets',
    totalStock: 5000,
    allocated: 4800,
    remaining: 200,
    threshold: 500,
    required: 2500,
    stockPercentage: 8,
    status: 'critical',
    center: 'Regional Warehouse B',
    projectedDepleteDate: '2023-09-05',
    lastUpdated: 'Aug 12, 2023'
  },
  {
    id: 3,
    name: 'Vitamin A Syrup',
    totalStock: 1200,
    allocated: 950,
    remaining: 250,
    threshold: 300,
    required: 1000,
    stockPercentage: 25,
    status: 'low',
    center: 'Regional Warehouse C',
    projectedDepleteDate: '2023-09-20',
    lastUpdated: 'Aug 09, 2023'
  },
  {
    id: 4,
    name: 'Growth Formula',
    totalStock: 3000,
    allocated: 2200,
    remaining: 800,
    threshold: 500,
    required: 1500,
    stockPercentage: 53.3,
    status: 'normal',
    center: 'Regional Warehouse A',
    projectedDepleteDate: '2023-11-15',
    lastUpdated: 'Aug 05, 2023'
  },
  {
    id: 5,
    name: 'Calcium Tablets',
    totalStock: 4000,
    allocated: 3200,
    remaining: 800,
    threshold: 500,
    required: 1800,
    stockPercentage: 44.4,
    status: 'normal',
    center: 'Regional Warehouse D',
    projectedDepleteDate: '2023-10-30',
    lastUpdated: 'Aug 08, 2023'
  },
  {
    id: 6,
    name: 'Micronutrient Sachets',
    totalStock: 1500,
    allocated: 1350,
    remaining: 150,
    threshold: 300,
    required: 1200,
    stockPercentage: 12.5,
    status: 'critical',
    center: 'Regional Warehouse B',
    projectedDepleteDate: '2023-09-10',
    lastUpdated: 'Aug 11, 2023'
  }
];

const recentDistributions = [
  {
    id: 1,
    center: 'Anganwadi Center 1',
    items: 'Protein Supplement, Iron Tablets',
    quantity: 250,
    date: 'Aug 15, 2023',
    status: 'delivered'
  },
  {
    id: 2,
    center: 'Anganwadi Center 3',
    items: 'Vitamin A Syrup, Growth Formula',
    quantity: 180,
    date: 'Aug 12, 2023',
    status: 'in-transit'
  },
  {
    id: 3,
    center: 'Anganwadi Center 2',
    items: 'Calcium Tablets, Iron Tablets',
    quantity: 300,
    date: 'Aug 10, 2023',
    status: 'delivered'
  }
];

// Updated pending requests with specific medicine details
const pendingRequests = [
  {
    id: 1,
    center: 'Anganwadi Center 5',
    requestDate: 'Aug 16, 2023',
    status: 'pending',
    medicines: [
      { name: 'Iron Tablets', quantity: 120, unit: 'Bottles' },
      { name: 'Micronutrient Sachets', quantity: 80, unit: 'Boxes' }
    ]
  },
  {
    id: 2,
    center: 'Anganwadi Center 2',
    requestDate: 'Aug 15, 2023',
    status: 'pending',
    medicines: [
      { name: 'Protein Supplement', quantity: 85, unit: 'Packets' },
      { name: 'Calcium Tablets', quantity: 65, unit: 'Bottles' }
    ]
  },
  {
    id: 3,
    center: 'Anganwadi Center 7',
    requestDate: 'Aug 14, 2023',
    status: 'pending',
    medicines: [
      { name: 'Vitamin A Syrup', quantity: 100, unit: 'Bottles' }
    ]
  }
];

const Inventory = () => {
  const { toast } = useToast();
  const [activeTab, setActiveTab] = useState('overview');
  const [selectedRequest, setSelectedRequest] = useState<(typeof pendingRequests)[0] | null>(null);
  
  const getStockColor = (status: string) => {
    switch (status) {
      case 'critical':
        return 'bg-red-500';
      case 'low':
        return 'bg-yellow-500';
      case 'normal':
        return 'bg-green-500';
      default:
        return 'bg-gray-500';
    }
  };
  
  const getStockBgColor = (status: string) => {
    switch (status) {
      case 'critical':
        return 'bg-red-100';
      case 'low':
        return 'bg-yellow-100';
      case 'normal':
        return 'bg-green-100';
      default:
        return 'bg-gray-100';
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'critical':
        return <span className="bg-red-100 text-red-700 text-xs px-2 py-1 rounded-full">Critical</span>;
      case 'low':
        return <span className="bg-yellow-100 text-yellow-700 text-xs px-2 py-1 rounded-full">Low Stock</span>;
      case 'normal':
        return <span className="bg-green-100 text-green-700 text-xs px-2 py-1 rounded-full">Normal</span>;
      default:
        return null;
    }
  };
  
  const getDistributionStatusBadge = (status: string) => {
    switch (status) {
      case 'delivered':
        return <span className="bg-green-100 text-green-700 text-xs px-2 py-1 rounded-full">Delivered</span>;
      case 'in-transit':
        return <span className="bg-blue-100 text-blue-700 text-xs px-2 py-1 rounded-full">In Transit</span>;
      default:
        return null;
    }
  };

  const getUrgencyBadge = (urgency: string) => {
    switch (urgency) {
      case 'high':
        return <span className="bg-red-100 text-red-700 text-xs px-2 py-1 rounded-full">High</span>;
      case 'medium':
        return <span className="bg-yellow-100 text-yellow-700 text-xs px-2 py-1 rounded-full">Medium</span>;
      case 'low':
        return <span className="bg-blue-100 text-blue-700 text-xs px-2 py-1 rounded-full">Low</span>;
      default:
        return null;
    }
  };

  const handleRequestAction = (id: number, action: 'approve' | 'reject') => {
    toast({
      title: `Request ${action === 'approve' ? 'Approved' : 'Rejected'}`,
      description: `Request #${id} has been ${action === 'approve' ? 'approved' : 'rejected'}.`,
      variant: action === 'approve' ? 'default' : 'destructive',
    });
    setSelectedRequest(null);
  };

  const handleRequestSelect = (request: (typeof pendingRequests)[0]) => {
    setSelectedRequest(request);
  };

  return (
    <Layout>
      <PageTitle 
        title="Inventory Management" 
        subtitle="Track and manage nutritional supplement inventory"
      >
        <Button className="bg-primary text-primary-foreground rounded-md px-4 py-2 text-sm font-medium flex items-center hover:bg-primary/90 transition-colors">
          <ShoppingBag size={16} className="mr-2" />
          Order Supplies
        </Button>
      </PageTitle>
      
      <Tabs defaultValue="overview" className="w-full" onValueChange={setActiveTab}>
        <TabsList className="mb-6">
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="requests">Pending Requests</TabsTrigger>
        </TabsList>
        
        <TabsContent value="overview">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
            <DashboardCard title="Current Stock" subtitle="All supplements">
              <div className="flex items-center mt-2">
                <div className="w-10 h-10 rounded-md bg-muted flex items-center justify-center mr-4">
                  <Package size={20} className="text-primary" />
                </div>
                <div>
                  <h4 className="text-2xl font-bold">15,650</h4>
                  <p className="text-xs text-muted-foreground">Units</p>
                </div>
              </div>
            </DashboardCard>
            
            <DashboardCard title="Low Stock Items" subtitle="Below threshold">
              <div className="flex items-center mt-2">
                <div className="w-10 h-10 rounded-md bg-red-100 flex items-center justify-center mr-4">
                  <AlertCircle size={20} className="text-red-500" />
                </div>
                <div>
                  <h4 className="text-2xl font-bold">4</h4>
                  <p className="text-xs text-muted-foreground">Items</p>
                </div>
              </div>
            </DashboardCard>
            
            <DashboardCard title="Pending Deliveries" subtitle="In transit">
              <div className="flex items-center mt-2">
                <div className="w-10 h-10 rounded-md bg-blue-100 flex items-center justify-center mr-4">
                  <Truck size={20} className="text-blue-500" />
                </div>
                <div>
                  <h4 className="text-2xl font-bold">3</h4>
                  <p className="text-xs text-muted-foreground">Deliveries</p>
                </div>
              </div>
            </DashboardCard>
            
            <DashboardCard title="Monthly Distribution" subtitle="August 2023">
              <div className="flex items-center mt-2">
                <div className="w-10 h-10 rounded-md bg-green-100 flex items-center justify-center mr-4">
                  <ShoppingBag size={20} className="text-green-500" />
                </div>
                <div>
                  <h4 className="text-2xl font-bold">4,230</h4>
                  <p className="text-xs text-muted-foreground">Units distributed</p>
                </div>
              </div>
            </DashboardCard>
          </div>
          
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
            <DashboardCard title="Supplement Inventory" subtitle="Current stock levels">
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead className="text-muted-foreground text-left border-b">
                    <tr>
                      <th className="px-4 py-3 font-medium">Supplement</th>
                      <th className="px-4 py-3 font-medium">Total</th>
                      <th className="px-4 py-3 font-medium">Allocated</th>
                      <th className="px-4 py-3 font-medium">Remaining</th>
                      <th className="px-4 py-3 font-medium">Status</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y">
                    {supplements.map((item) => (
                      <tr key={item.id} className="hover:bg-muted/50 transition-colors">
                        <td className="px-4 py-3 font-medium">{item.name}</td>
                        <td className="px-4 py-3 text-muted-foreground">{item.totalStock}</td>
                        <td className="px-4 py-3 text-muted-foreground">{item.allocated}</td>
                        <td className="px-4 py-3 text-muted-foreground">{item.remaining}</td>
                        <td className="px-4 py-3">{getStatusBadge(item.status)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </DashboardCard>
            
            <DashboardCard title="Recent Distributions" subtitle="Last 30 days">
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead className="text-muted-foreground text-left border-b">
                    <tr>
                      <th className="px-4 py-3 font-medium">Center</th>
                      <th className="px-4 py-3 font-medium">Items</th>
                      <th className="px-4 py-3 font-medium">Quantity</th>
                      <th className="px-4 py-3 font-medium">Date</th>
                      <th className="px-4 py-3 font-medium">Status</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y">
                    {recentDistributions.map((item) => (
                      <tr key={item.id} className="hover:bg-muted/50 transition-colors">
                        <td className="px-4 py-3 font-medium">{item.center}</td>
                        <td className="px-4 py-3 text-muted-foreground">{item.items}</td>
                        <td className="px-4 py-3 text-muted-foreground">{item.quantity}</td>
                        <td className="px-4 py-3 text-muted-foreground">{item.date}</td>
                        <td className="px-4 py-3">{getDistributionStatusBadge(item.status)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </DashboardCard>
          </div>
        </TabsContent>
        
        <TabsContent value="requests">
          <div className="grid grid-cols-1 gap-6 mb-6">
            <DashboardCard title="Pending Supplement Requests" subtitle="Awaiting review and approval">
              <div className="overflow-x-auto">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Request ID</TableHead>
                      <TableHead>Center</TableHead>
                      <TableHead>Date</TableHead>
                      <TableHead>Action</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {pendingRequests.map((item) => (
                      <TableRow 
                        key={item.id} 
                        className="cursor-pointer hover:bg-muted/50"
                        onClick={() => handleRequestSelect(item)}
                      >
                        <TableCell className="font-medium">#{item.id}</TableCell>
                        <TableCell>{item.center}</TableCell>
                        <TableCell>{item.requestDate}</TableCell>
                        <TableCell>
                          <div className="flex space-x-2">
                            <Button 
                              variant="ghost" 
                              size="sm" 
                              className="h-8 bg-green-100 text-green-700 hover:bg-green-200"
                              onClick={(e) => {
                                e.stopPropagation();
                                handleRequestAction(item.id, 'approve');
                              }}
                            >
                              Approve
                            </Button>
                            <Button 
                              variant="ghost" 
                              size="sm" 
                              className="h-8 bg-red-100 text-red-700 hover:bg-red-200"
                              onClick={(e) => {
                                e.stopPropagation();
                                handleRequestAction(item.id, 'reject');
                              }}
                            >
                              Reject
                            </Button>
                          </div>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </div>
            </DashboardCard>
          </div>
        </TabsContent>
      </Tabs>
      
      {/* Request Details Dialog */}
      <Dialog open={!!selectedRequest} onOpenChange={(open) => !open && setSelectedRequest(null)}>
        <DialogContent className="sm:max-w-[500px]">
          <DialogHeader>
            <DialogTitle>Request Details - #{selectedRequest?.id}</DialogTitle>
          </DialogHeader>
          
          <div className="py-4">
            <div className="grid gap-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <p className="text-sm font-medium">Center</p>
                  <p className="text-sm text-muted-foreground">{selectedRequest?.center}</p>
                </div>
                <div>
                  <p className="text-sm font-medium">Date Requested</p>
                  <p className="text-sm text-muted-foreground">{selectedRequest?.requestDate}</p>
                </div>
              </div>
              
              <div>
                <p className="text-sm font-medium mb-2">Urgency</p>
                {selectedRequest && getUrgencyBadge(selectedRequest.urgency)}
              </div>
              
              <Card className="p-4">
                <h3 className="text-sm font-medium mb-3">Requested Medicines</h3>
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Medicine</TableHead>
                      <TableHead>Quantity</TableHead>
                      <TableHead>Unit</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {selectedRequest?.medicines.map((medicine, index) => (
                      <TableRow key={index}>
                        <TableCell className="font-medium">{medicine.name}</TableCell>
                        <TableCell>{medicine.quantity}</TableCell>
                        <TableCell>{medicine.unit}</TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </Card>
            </div>
          </div>
          
          <DialogFooter>
            <Button variant="outline" onClick={() => setSelectedRequest(null)}>
              Cancel
            </Button>
            <Button 
              className="bg-green-600 hover:bg-green-700 text-white"
              onClick={() => selectedRequest && handleRequestAction(selectedRequest.id, 'approve')}
            >
              Approve Request
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </Layout>
  );
};

export default Inventory;
