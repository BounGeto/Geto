#include <iostream>
#include <TROOT.h>
#include <TApplication.h>

#include "ViewField.hh"
#include "ViewCell.hh"
#include "ComponentAnalyticField.hh"
#include "MediumMagboltz.hh"
#include "SolidBox.hh"
#include "GeometrySimple.hh"
#include "Sensor.hh"
#include "ViewDrift.hh"
#include "FundamentalConstants.hh"
#include "DriftLineRKF.hh"
#include "ViewMedium.hh"
#include "ViewSignal.hh"
#include "Random.hh"
#include "TrackHeed.hh"
#include "AvalancheMicroscopic.hh"


using namespace Garfield;

double transfer(double t){
  const double tau = 160;
  const double fC_to_mV = 12.7;
  return fC_to_mV*exp(4)*pow((t/tau),4)*exp(-4*t/tau);  //impulse response of the PASA

}

int main(int argc, char * argv[]) {

  TApplication app("app", &argc, argv);
  
  //box dimensions
  const double length = 10; // in cm
  const double gap = 0.5; // in cm
  const double anode_spacing = 0.4; // in cm
  const double cathode_spacing = 0.2; // in cm
  
  // Wire diameters
  const double d_anode = 0.0020; //in cm
  const double d_cathode = 0.0100; //in cm
  
  const double voltage = 2000; // in V
  
  // Setup the gas
  const double pressure = 750.; //Torr = 1atm
  const double temperature = 293.15; //K
  
  //number of wires
  int n_anode = length / anode_spacing - 1;
  int n_cathode = length / cathode_spacing - 1;
  
  
  // Make a gas medium
  MediumMagboltz* gas = new MediumMagboltz();
  // Set the temperature [K] and pressure [Torr]
  gas->SetTemperature(temperature);
  gas->SetPressure(pressure);
  gas->SetComposition("ar", 50., "co2", 50.);

  //Read from .gas file
  gas->LoadGasFile("ar_50_co2_50.gas");
  gas->LoadIonMobility("IonMobility_Ar+_Ar.txt");
  
  // Build the geometry
  // z=0 anode layer
  // z=+-gap cathode planes
  GeometrySimple* geo = new GeometrySimple();
  SolidBox* box = new SolidBox(0., 0., 0.,gap,length/2,length/2);

  // Add the solid to the geometry, together with the medium inside
  geo->AddSolid(box, gas);
  
  double xmin,ymin,zmin,xmax,ymax,zmax;
  box->GetBoundingBox(xmin,ymin,zmin,xmax,ymax,zmax);
  
  std::cout << "minimum and maximum coordinates of the box are: " << std::endl;
  std::cout << "(" << xmin << " " << ymin << " " << zmin << ")  (" << xmax << " " << ymax << " " << zmax << ")" << std::endl;

  
  // Setup the electric field
  ComponentAnalyticField* comp_e = new ComponentAnalyticField();
  
  //adding anode wires
  for (int i = 0; i < n_anode; ++i) {
   double x = 0;
   double y = (-length/2 + (double)(i+1) * anode_spacing );
   comp_e->AddWire( x,y , d_anode, voltage, "a");
   std::cout << i+1 <<"th anode wire added to \tx = " << x << " \ty = " << y << std::endl;
  }
  comp_e->AddReadout("a");

  comp_e -> AddPlaneX(-gap, 0, "cp-");
  //at distance gap with potential zero.
  comp_e -> AddPlaneX(gap, 0., "cp+");
  
  // parameters: y direction 
  comp_e->AddStripOnPlaneX('y', gap, -length/2.,length/2., "cp+1");
  //comp_e->AddStripOnPlaneX('y', gap, 0,length/2, "cp+2");
  //comp_e->AddStripOnPlaneX('y', gap, 5,5.5, "cp+2");
  
  comp_e->AddReadout("cp-");
  comp_e->AddReadout("cp+");
  comp_e->AddReadout("cp+1");
  //comp_e->AddReadout("cp+2");
  
  
  //Add magnetic field
  comp_e->SetMagneticField(0,0,0);
  comp_e->SetGeometry(geo);

  //create a canvas that will also be used for drift lines plotting
  TCanvas* myCanvas = new TCanvas();
  ViewCell* cellView = new ViewCell();
  cellView->SetComponent(comp_e);
  cellView->SetArea(-gap,-length/2,-length/2,gap,length/2,length/2);
  cellView->SetCanvas(myCanvas);
  cellView->Plot3d();
  myCanvas->Update();
  
  
  // Make a sensor for ions (gating closed)
  Sensor* sensor_e = new Sensor();
  sensor_e->AddComponent(comp_e);
  sensor_e->AddElectrode(comp_e, "a");
  sensor_e->AddElectrode(comp_e, "cp-");
  sensor_e->AddElectrode(comp_e, "cp+");
  sensor_e->AddElectrode(comp_e, "cp+1");
  //sensor_e->AddElectrode(comp_e, "cp+2");
  sensor_e->SetTimeWindow(0.,100,400); // can be changed for less/better resolution in time (effect on convolution can be important)
 
  //Plot drift line
  DriftLineRKF* driftline = new DriftLineRKF();
  driftline->SetSensor(sensor_e);
  
  const double gain = 1;
  double r = gap/2;
  double dummy = 0.;
  int status=0;
  double endpoint = gap;
  int plane = 0, cathode= 0, gate = 0, escape = 0; // used to store number of ions that drift respectively to plane, cathode, gate or drift vol
  for(int i=0; i<gain; i++){
    //if(i%100==0) 
    std::cout << i << std::endl;
    driftline->DriftElectron(0,0,0,0);
    std::cout << i << std::endl;
    driftline->GetEndPoint(dummy,endpoint,dummy,dummy,status);
  }
 
  // Plot isopotential contours
  ViewField* fView = new ViewField;
  fView->SetSensor(sensor_e);
  fView->SetArea(-gap,-length/2,gap,length/2);
  fView->SetVoltageRange(-100., 1000.);
  fView->PlotContour();
  
    
  sensor_e->SetTransferFunction(transfer);
  sensor_e->ConvoluteSignal();
  
  // Plot signal
  ViewSignal* vs1 = new ViewSignal();
  vs1->SetSensor(sensor_e);
  vs1->PlotSignal("a");

  ViewSignal* vs2 = new ViewSignal();
  vs2->SetSensor(sensor_e);
  vs2->PlotSignal("cp+");
  
  ViewSignal* vs3 = new ViewSignal();
  vs3->SetSensor(sensor_e);
  vs3->PlotSignal("cp-");
  
  app.Run(kTRUE);

}
