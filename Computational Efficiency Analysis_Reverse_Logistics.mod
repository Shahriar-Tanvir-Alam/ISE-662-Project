/*********************************************
 * OPL 12.6.1.0 Model
 * Author: Shahriar Tanvir Alam
 * Creation Date: Mar 31, 2024 at 1:07:50 AM
 *********************************************/
 
//ISE 662 (Computational Efficiency Analysis_Reverse_Logistics)

// Indices
int Nretailer_areas=...;
range retailer_areas=1..Nretailer_areas; //l

int Ncustomer_areas=...;
range customer_areas=1..Ncustomer_areas; //m

int Nremanufacturing_centers=...;
range remanufacturing_centers=1..Nremanufacturing_centers; //n

int Ninventories=...;
range inventories=1..Ninventories; //p

int Ndemand_center=...;
range demand_center=1..Ndemand_center; //k

int Ndisposal_centers=...;
range disposal_centers=1..Ndisposal_centers; //r

{string} products=...; //s

//Parameters
// Parameters

//demands
float demand_demand_Center[products][demand_center] = ...; // Demand of product s in demand center k
float demand_remanufacturing_centers[products][remanufacturing_centers]=...;

float return_rate_customer[products][remanufacturing_centers] = ...; // Rate of return of used product s from customer area m to remanufacturing center n
float return_rate_remanufacturing[products][inventories] = ...; // Ratr for  product s from remanufacturing center n to inventory p
//float return_rate_inventory[products][demand_center] = ...; // Rate of return of recovered product s from inventory p to demand center k
float fixed_cost_remanufacturing[remanufacturing_centers] = ...; // Fixed costs of establishing remanufacturing center n
float fixed_cost_inventory[inventories] = ...; // Fixed costs of establishing inventory p
float fixed_cost_disposal[disposal_centers] = ...; // Fixed costs of establishing disposal center r

float cost_transport_retailer[products][retailer_areas][remanufacturing_centers] = ...; // Cost of transporting used product s from retailer area l to remanufacturing center n (per unit per km)
float cost_transport_customer[products][customer_areas][remanufacturing_centers] = ...; // Cost of transporting used product s from customer area m to remanufacturing center n (per unit per km)
float cost_transport_remanufacturing[products][remanufacturing_centers][disposal_centers] = ...; // Cost of transporting used product s from remanufacturing center n to disposal center r (per unit per km)
float cost_transport_inventory[products][remanufacturing_centers][inventories] = ...; // Cost of transporting used product s from remanufacturing center n to inventory p (per unit per km)
float cost_transport_demand[products][inventories][demand_center] = ...; // Cost of transporting used product s from inventory p to demand center n (per unit per km)
float distance_retailer[products][retailer_areas][remanufacturing_centers] = ...; // Distance between retailer center l to remanufacturing center n (km)
float distance_customer[products][customer_areas][remanufacturing_centers] = ...; // Distance between customer area m to remanufacturing center n (km)
float distance_remanufacturing[products][remanufacturing_centers][disposal_centers] = ...; // Distance between remanufacturing center n to disposal center r (km)
float distance_inventory[products][remanufacturing_centers][inventories] = ...; // Distance between remanufacturing center n to inventory p (km)
float distance_demand[products][inventories][demand_center] = ...; // Distance between inventory p to demand center n (km)
float cost_stocking[products][inventories] = ...; // Cost of stocking a unit of product s in inventory p for demand center km

float capacity_remanufacturing[remanufacturing_centers] = ...; // Capacity of remanufacturing center n
float capacity_inventory[inventories] = ...; // Capacity of inventory p
float capacity_disposal[disposal_centers] = ...; // Capacity of disposal center r

// Decision Variables



dvar float+ quantity_retailer_areas_to_remanufacturing_centers[products][retailer_areas][remanufacturing_centers]; // Quantity transported from retailer area l to remanufacturing center n
dvar float+ quantity_customer_areas_to_remanufacturing_centers[products][customer_areas][remanufacturing_centers]; // Quantity transported from customer area m to remanufacturing center n
dvar float+ quantity_remanufacturing_centers_to_inventories[products][remanufacturing_centers][inventories]; // Quantity transported from remanufacturing center n to inventory p
dvar float+ quantity_remanufacturing_centers_to_disposal_centers[products][remanufacturing_centers][disposal_centers]; // Quantity transported from remanufacturing center n to disposal center r
dvar float+ quantity_inventories_to_demand_center[products][inventories][demand_center]; // Quantity transported from inventory p to demand center k
dvar boolean remanufacturing_centers_established[remanufacturing_centers]; // 1 if remanufacturing center n is established, 0 otherwise
dvar boolean inventories_established[inventories]; // 1 if inventory p is established, 0 otherwise
dvar boolean disposal_centers_established[disposal_centers]; // 1 if disposal center r is established, 0 otherwise
dvar float+ quantity_remaining_in_inventories[products][inventories]; // Quantity of product s remaining in the inventory

// Objective Function
minimize
    sum(n in remanufacturing_centers) fixed_cost_remanufacturing[n] * remanufacturing_centers_established[n] +
    sum(p in inventories) fixed_cost_inventory[p] * inventories_established[p] +
    sum(r in disposal_centers) fixed_cost_disposal[r] * disposal_centers_established[r] +
    
    
    sum(s in products, n in remanufacturing_centers, p in inventories) cost_transport_inventory[s][n][p] * distance_inventory[s][n][p] * quantity_remanufacturing_centers_to_inventories[s][n][p] +
    sum(s in products, l in retailer_areas, n in remanufacturing_centers) cost_transport_retailer[s][l][n] * distance_retailer[s][l][n] * quantity_retailer_areas_to_remanufacturing_centers[s][l][n] +
    sum(s in products, m in customer_areas, n in remanufacturing_centers) cost_transport_customer[s][m][n] * distance_customer[s][m][n] * quantity_customer_areas_to_remanufacturing_centers[s][m][n] +
    sum(s in products, n in remanufacturing_centers, r in disposal_centers) cost_transport_remanufacturing[s][n][r] * distance_remanufacturing[s][n][r] * quantity_remanufacturing_centers_to_disposal_centers[s][n][r] +
    sum(s in products, p in inventories, k in demand_center) cost_transport_demand[s][p][k] * distance_demand[s][p][k] * quantity_inventories_to_demand_center[s][p][k] 
    + sum(s in products, p in inventories) cost_stocking[s][p] * quantity_remaining_in_inventories[s][p];
    
subject to {

//s ADD


forall(s in products,n in remanufacturing_centers)
sum(m in customer_areas, n in remanufacturing_centers)
quantity_customer_areas_to_remanufacturing_centers[s][m][n] ==demand_remanufacturing_centers[s][n]*return_rate_customer[s][n];

forall(s in products,n in remanufacturing_centers)
sum(l in retailer_areas, n in remanufacturing_centers) quantity_retailer_areas_to_remanufacturing_centers[s][l][n]==demand_remanufacturing_centers[s][n]*(1-return_rate_customer[s][n]);




forall(s in products)
    sum(l in retailer_areas, n in remanufacturing_centers) quantity_retailer_areas_to_remanufacturing_centers[s][l][n] +
    sum(m in customer_areas, n in remanufacturing_centers) quantity_customer_areas_to_remanufacturing_centers[s][m][n] ==
    sum(n in remanufacturing_centers, p in inventories) quantity_remanufacturing_centers_to_inventories[s][n][p] +
    sum(n in remanufacturing_centers, r in disposal_centers) quantity_remanufacturing_centers_to_disposal_centers[s][n][r]; // Constraint 25
    
    forall(s in products, n in remanufacturing_centers, p in inventories)
    quantity_remanufacturing_centers_to_inventories[s][n][p] ==
    return_rate_remanufacturing[s][p] * 
    (sum(l in retailer_areas) quantity_retailer_areas_to_remanufacturing_centers[s][l][n] +
    sum(m in customer_areas) quantity_customer_areas_to_remanufacturing_centers[s][m][n]);
    
    forall(n in remanufacturing_centers, s in products,r in disposal_centers,p in inventories)
        sum(r in disposal_centers) quantity_remanufacturing_centers_to_disposal_centers[s][n][r] ==
        (1 - return_rate_remanufacturing[s][p]) * (sum(l in retailer_areas) quantity_retailer_areas_to_remanufacturing_centers[s][l][n] + sum(m in customer_areas) quantity_customer_areas_to_remanufacturing_centers[s][m][n]); // Constraint 14
    
    forall(s in products, k in demand_center)
    sum(p in inventories) quantity_inventories_to_demand_center[s][p][k] == demand_demand_Center[s][k];
    
    forall(n in remanufacturing_centers)
    sum(s in products, l in retailer_areas) quantity_retailer_areas_to_remanufacturing_centers[s][l][n] +
    sum(s in products, m in customer_areas) quantity_customer_areas_to_remanufacturing_centers[s][m][n] <=
    capacity_remanufacturing[n] * remanufacturing_centers_established[n];

forall(p in inventories)
    sum(s in products, n in remanufacturing_centers) quantity_remanufacturing_centers_to_inventories[s][n][p] <=
    capacity_inventory[p] * inventories_established[p];

forall(r in disposal_centers)
    sum(s in products, n in remanufacturing_centers) quantity_remanufacturing_centers_to_disposal_centers[s][n][r] <=
    capacity_disposal[r] * disposal_centers_established[r];
    
    
    forall(n in remanufacturing_centers, s in products)
        quantity_remaining_in_inventories[s][n] == sum(p in inventories) quantity_remanufacturing_centers_to_inventories[s][n][p] - sum(k in demand_center) quantity_inventories_to_demand_center[s][n][k]; // Constraint 19
    
    
    
    
    
    
    
    
    
    //flow cosntraints
    forall(s in products, l in retailer_areas, n in remanufacturing_centers)
    quantity_retailer_areas_to_remanufacturing_centers[s][l][n] >= 0;
    forall(s in products, m in customer_areas, n in remanufacturing_centers)
    quantity_customer_areas_to_remanufacturing_centers[s][m][n] >= 0;
    forall(s in products, n in remanufacturing_centers, p in inventories)
    quantity_remanufacturing_centers_to_inventories[s][n][p] >= 0;
    forall(s in products, n in remanufacturing_centers, r in disposal_centers)
    quantity_remanufacturing_centers_to_disposal_centers[s][n][r] >= 0;
    forall(s in products, p in inventories, k in demand_center)
    quantity_inventories_to_demand_center[s][p][k] >= 0;
     

}

 