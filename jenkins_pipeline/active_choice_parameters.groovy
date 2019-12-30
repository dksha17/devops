mport groovy.json.JsonSlurper
// Set the URL we want to read from, limited to 20 results only.
docker_image_tags_url = "https://*****/v2/abs-retail/scgo-itemlookup/${branch_name}/tags/list?page_size=20"
try {
    // Set requirements for the HTTP GET request, you can add Content-Type headers and so on...
    def http_client = new URL(docker_image_tags_url).openConnection() as HttpURLConnection
    def authString = "zduwenterprisecr:dHbMTsGMn40o7AXluI3bPM4453AiXdm/".getBytes().encodeBase64().toString()
    http_client.setRequestProperty( "Authorization", "Basic ${authString}" )
    http_client.setRequestMethod('GET')
    // Run the HTTP request
    http_client.connect()
    // Prepare a variable where we save parsed JSON as a HashMap, it's good for our use case, as we just need the 'name' of each tag.
    def dockerhub_response = [:]    
    // Check if we got HTTP 200, otherwise exit
    if (http_client.responseCode == 200) {
        dockerhub_response = new JsonSlurper().parseText(http_client.inputStream.getText('UTF-8'))
        //dockerhub_response = dockerhub_response.tags
        //println dockerhub_response
    } else {
        println("HTTP response error")
    }

    // Prepare the results list
    def acr_images = [];

    // Add all tags
    dockerhub_response.tags.each { 
      acr_images.add(it) } 

    // Return the list for Jenkins "select-box"
    return acr_images

} catch (Exception e) {
         // handle exceptions like timeout, connection errors, etc.
         println(e)
}
