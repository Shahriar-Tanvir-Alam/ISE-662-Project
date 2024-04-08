/*********************************************
 * OPL 12.6.1.0 Model
 * Author: Shahriar Tanvir Alam
 * Creation Date: Apr 1, 2024 at 12:19:34 AM
 *********************************************/
 
 //ISE 662 (Computational Efficiency Analysis with Additional Constraints_Forward_Logistics)
 
// Indices
int Nsupply_centers=2;
range supply_centers=1..Nsupply_centers; //i

int Nmanufacturing_centers=1;
range manufacturing_centers=1..Nmanufacturing_centers; //j

int Nadditionalmanufacturing_centers=1;
range additional_manufacturing_centers=1..Nadditionalmanufacturing_centers; //a

int Ndemand_centers=3;
range demand_centers=1..Ndemand_centers; //k

int Nretail_centers=2;
range retail_centers=1..Nretail_centers; //l

int Ncustomer_centers=3;
range customer_centers=1..Ncustomer_centers; //m

{string} products={"A", "B"}; //s

// Parameters

float demand_deamand_center[products][demand_centers]= ...;
float demand_customer_center[products][customer_centers] = ...; // Demand of product s in customer center m
float capacity_supply_center[supply_centers] = ...; // Capacity of supply center i
float capacity_manufacturing_center[manufacturing_centers] = ...; // Capacity of manufacturing center j
float capacity_additional_manufacturing_center[additional_manufacturing_centers] = ...; // Capacity of manufacturing center a
float capacity_demand_center[demand_centers] = ...; // Capacity of demand center k
float capacity_retail_center[retail_centers] = ...; // Capacity of retail center l
float cost_supply_to_manufacturing[products][supply_centers][manufacturing_centers] = ...; // Cost of transporting product s from supply center i to manufacturing center j
float cost_supply_to_additional_manufacturing[products][supply_centers][additional_manufacturing_centers] = ...; // Cost of transporting product s from supply center i to manufacturing center a

float cost_manufacturing_to_demand[products][manufacturing_centers][demand_centers] = ...; // Cost of transporting product s from manufacturing center j to demand center k
float cost_additional_manufacturing_to_demand[products][additional_manufacturing_centers][demand_centers] = ...; // Cost of transporting product s from manufacturing center a to demand center k
float cost_demand_to_retail[products][demand_centers][retail_centers] = ...; // Cost of transporting product s from demand center k to retail center l
float cost_retail_to_customer[products][retail_centers][customer_centers] = ...; // Cost of transporting product s from retail center l to customer center m
float demand_fulfillment_percentage [products]= ...; // The percentage of demand at the demand center that is fulfilled
float cost_subcontract[additional_manufacturing_centers]=...;




// Decision Variables
dvar float+ quantity_supply_centers_to_manufacturing_centers[products][supply_centers][manufacturing_centers]; // Quantity transported from supply center i to manufacturing center j
dvar float+ quantity_manufacturing_centers_to_demand_centers[products][manufacturing_centers][demand_centers]; // Quantity transported from manufacturing center j to demand center k
dvar float+ quantity_supply_centers_to_additional_manufacturing_centers[products][supply_centers][additional_manufacturing_centers]; // Quantity transported from supply center i to manufacturing center a
dvar float+ quantity_additional_manufacturing_centers_to_demand_centers[products][additional_manufacturing_centers][demand_centers]; // Quantity transported from manufacturing center a to demand center k
dvar float+ quantity_demand_centers_to_retail_centers[products][demand_centers][retail_centers]; // Quantity transported from demand center k to retail center l
dvar float+ quantity_retail_centers_to_customer_centers[products][retail_centers][customer_centers]; // Quantity transported from retail center l to customer center m
dvar float+ unmet_demand[products][demand_centers]; // Unmet demand for each product at each demand center

dvar boolean rent[additional_manufacturing_centers];//y
// Objective Function


minimize
    sum(a in additional_manufacturing_centers) cost_subcontract[a]*rent[a]+
    sum(s in products, i in supply_centers, j in manufacturing_centers) cost_supply_to_manufacturing[s][i][j] * quantity_supply_centers_to_manufacturing_centers[s][i][j] +
    sum(s in products, i in supply_centers, a in additional_manufacturing_centers) cost_supply_to_manufacturing[s][i][a] * quantity_supply_centers_to_additional_manufacturing_centers[s][i][a] +
    sum(s in products, j in manufacturing_centers, k in demand_centers) cost_manufacturing_to_demand[s][j][k] * quantity_manufacturing_centers_to_demand_centers[s][j][k] +
    sum(s in products, a in additional_manufacturing_centers, k in demand_centers) cost_manufacturing_to_demand[s][a][k] * quantity_additional_manufacturing_centers_to_demand_centers[s][a][k] +
    sum(s in products, k in demand_centers, l in retail_centers) cost_demand_to_retail[s][k][l] * quantity_demand_centers_to_retail_centers[s][k][l] +
    sum(s in products, l in retail_centers, m in customer_centers) cost_retail_to_customer[s][l][m] * quantity_retail_centers_to_customer_centers[s][l][m];

// Constraints

subject to {



// Flow conservation at manufacturing centers
forall(s in products, j in manufacturing_centers)
    sum(i in supply_centers) quantity_supply_centers_to_manufacturing_centers[s][i][j] <=
    sum(k in demand_centers) quantity_manufacturing_centers_to_demand_centers[s][j][k];

forall(s in products, a in additional_manufacturing_centers)
    sum(i in supply_centers) quantity_supply_centers_to_manufacturing_centers[s][i][a] <=
    sum(k in demand_centers) quantity_manufacturing_centers_to_demand_centers[s][a][k];

  
  
  // Constraints
// Add a constraint to calculate the unmet demand
forall(s in products, k in demand_centers)
    unmet_demand[s][k] == demand_deamand_center[s][k] - demand_fulfillment_percentage[s] * demand_deamand_center[s][k];

// Modify the flow conservation at demand centers to distribute the fulfilled demand between the retail centers and customer centers
forall(s in products, k in demand_centers, a in additional_manufacturing_centers)
    sum(j in manufacturing_centers) quantity_manufacturing_centers_to_demand_centers[s][j][k] +
    sum(a in additional_manufacturing_centers) quantity_additional_manufacturing_centers_to_demand_centers[s][a][k]<=
    demand_fulfillment_percentage[s] * demand_deamand_center[s][k];

// Modify the demand constraints at customer centers to ensure that the demand is met
forall(s in products, m in customer_centers,k in demand_centers,l in retail_centers)
    sum(k in demand_centers) quantity_demand_centers_to_retail_centers[s][k][l]<= demand_fulfillment_percentage[s] * demand_deamand_center[s][k];
  
  // Flow conservation at retail centers
forall(s in products, l in retail_centers)
    sum(m in customer_centers) quantity_retail_centers_to_customer_centers[s][l][m] <=
    sum(k in demand_centers) quantity_demand_centers_to_retail_centers[s][k][l];
  
 //AG 
  // Demand constraints at customer centers
forall(s in products, m in customer_centers)
    sum(l in retail_centers) quantity_retail_centers_to_customer_centers[s][l][m] >= demand_customer_center[s][m];

// Flow conservation at manufacturing centers
forall(s in products, j in manufacturing_centers, a in additional_manufacturing_centers)
    sum(i in supply_centers) quantity_supply_centers_to_manufacturing_centers[s][i][j] +
    sum(i in supply_centers) quantity_supply_centers_to_additional_manufacturing_centers[s][i][a] ==
    sum(k in demand_centers) quantity_manufacturing_centers_to_demand_centers[s][j][k] +
    sum(k in demand_centers) quantity_additional_manufacturing_centers_to_demand_centers[s][a][k];

// Flow conservation at demand centers
forall(s in products, k in demand_centers)
    sum(j in manufacturing_centers) quantity_manufacturing_centers_to_demand_centers[s][j][k] +
    sum(a in additional_manufacturing_centers) quantity_additional_manufacturing_centers_to_demand_centers[s][a][k]==
    sum(l in retail_centers) quantity_demand_centers_to_retail_centers[s][k][l];

// Flow conservation at retail centers
forall(s in products, l in retail_centers)
    sum(k in demand_centers) quantity_demand_centers_to_retail_centers[s][k][l] ==
    sum(m in customer_centers) quantity_retail_centers_to_customer_centers[s][l][m];
  
  
  
  
  
    
    //capacity
forall(j in manufacturing_centers)
    sum(s in products, i in supply_centers) quantity_supply_centers_to_manufacturing_centers[s][i][j] <= capacity_manufacturing_center[j];

forall(a in additional_manufacturing_centers)
    sum(s in products, i in supply_centers) quantity_supply_centers_to_additional_manufacturing_centers[s][i][a] <= capacity_manufacturing_center[a]*rent[a];

forall(k in demand_centers)
    sum(s in products, j in manufacturing_centers) quantity_manufacturing_centers_to_demand_centers[s][j][k] <= capacity_demand_center[k];

forall(l in retail_centers)
    sum(s in products, k in demand_centers) quantity_demand_centers_to_retail_centers[s][k][l] <= capacity_retail_center[l];
  
  
  forall(s in products, i in supply_centers, j in manufacturing_centers)
    quantity_supply_centers_to_manufacturing_centers[s][i][j] >= 0;

forall(s in products, i in supply_centers, a in additional_manufacturing_centers)
    quantity_supply_centers_to_manufacturing_centers[s][i][a] >= 0;
    
forall(s in products, j in manufacturing_centers, k in demand_centers)
    quantity_manufacturing_centers_to_demand_centers[s][j][k] >= 0;

forall(s in products, k in demand_centers, l in retail_centers)
    quantity_demand_centers_to_retail_centers[s][k][l] >= 0;

forall(s in products, l in retail_centers, m in customer_centers)
    quantity_retail_centers_to_customer_centers[s][l][m] >= 0;} 

 