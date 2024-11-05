import requests

# API base URL and headers
base_url = "https://statuspage.lingiops.com/api"
api_token = '2a53a2b773eec02d83c77e9bf430fb1d77e03084'
headers = {
    "Authorization": f"Token {api_token}",
    "Content-Type": "application/json"
}

# Step 1: Retrieve the list of components
components_url = f"{base_url}/components/components/"
response = requests.get(components_url, headers=headers)

# Check if the request to get components was successful
if response.status_code == 200:
    components_data = response.json()

    # Loop through each component and perform the update
    for component in components_data.get('results', []):
        component_id = component['id']
        component_name = component['name']
        component_status = component['status']
        component_status_url = component['link']  # Assuming 'link' points to the URL for updating status
        print(f"Processing Component - ID: {component_id}, Name: {component_name}, Link: {component_status_url}")

        # Check if the component's status URL is reachable without headers
        url_response = requests.get(component_status_url)

        if url_response.status_code != 200:
            print(
                f"Component '{component_name}' is unreachable, status code"
                f" {url_response.status_code}.")

            # 2. Update component status if it's not already "unknown"
            if component_status != "unknown":
                component_update_data = {
                    "name": component_name,
                    "status": "unknown"
                }
                response_component = requests.put(f"{components_url}{component_id}/", headers=headers,
                                                  json=component_update_data)
                if response_component.status_code == 200:
                    print(f"Component '{component_name}' status updated to 'unknown' successfully.")

                    # 3. Create a new incident involving the component
                    incident_data = {
                        "title": f"Incident affecting {component_name}",
                        "visibility": True,
                        "status": "investigating",
                        "impact": "major",
                        "user": 1,
                        "components": [{"id": component_id}]
                    }

                    incident_url = f"{base_url}/incidents/incidents/"
                    response_incident = requests.post(incident_url, headers=headers, json=incident_data)

                    if response_incident.status_code == 201:
                        incident_id = response_incident.json().get('id')
                        print(f"New incident for '{component_name}' created successfully with ID {incident_id}.")

                        # 4. Post an incident update related to the component
                        incident_update_data = {
                            "text": (
                                f"Incident affecting {component_name} is being monitored.\n\n"
                                f"### Update Details\n- Current Status: Unknown\n"
                                f"- Impact: Major\n- Error Code: {url_response.status_code}"
                            ),
                            "incident": incident_id,
                            "user": 1
                        }

                        incident_update_url = f"{base_url}/incidents/incident-updates/"
                        response_incident_update = requests.post(incident_update_url, headers=headers,
                                                                 json=incident_update_data)

                        if response_incident_update.status_code == 201:
                            print(f"Incident update for '{component_name}' posted successfully.")
                        else:
                            print(
                                f"Failed to post incident update for '{component_name}': "
                                f"{response_incident_update.status_code}, {response_incident_update.text}")

                    else:
                        print(
                            f"Failed to create new incident for '{component_name}': "
                            f"{response_incident.status_code}, {response_incident.text}")

                else:
                    print(
                        f"Failed to update component '{component_name}': "
                        f"{response_component.status_code}, {response_component.text}")

else:
    print(f"Failed to retrieve components: {response.status_code}, {response.text}")

