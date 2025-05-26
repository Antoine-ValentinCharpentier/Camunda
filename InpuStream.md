Envoit de fichier

```
import org.apache.http.entity.ContentType;
import org.apache.http.entity.mime.MultipartEntityBuilder;
import org.apache.http.entity.mime.content.InputStreamBody;

import java.io.InputStream;
import java.net.URL;

URL url = new URL("http://example.com/monfichier.jpg");
try (InputStream inputStream = url.openStream()) {

    InputStreamBody inputStreamBody = new InputStreamBody(inputStream, ContentType.DEFAULT_BINARY, "monfichier.jpg");

    MultipartEntityBuilder builder = MultipartEntityBuilder.create();
    builder.setMode(HttpMultipartMode.LEGACY);
    builder.addPart("file", inputStreamBody);
    builder.addTextBody("text1", "This is message 1", ContentType.MULTIPART_FORM_DATA);
    builder.addTextBody("text2", "This is message 2", ContentType.MULTIPART_FORM_DATA);

    // builder.build() -> ton HttpEntity que tu peux envoyer avec HttpClient

} catch (Exception e) {
    e.printStackTrace();
}
```

Download
avec HttpUrlCOnnection (Java standard)
```
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;

URL url = new URL("http://tonserveur/api/download/test.txt");
HttpURLConnection connection = (HttpURLConnection) url.openConnection();
connection.setRequestMethod("GET");

int responseCode = connection.getResponseCode();
if (responseCode == HttpURLConnection.HTTP_OK) {
    InputStream inputStream = connection.getInputStream();
    // inputStream est prêt à être utilisé dans InputStreamBody ou autre
} else {
    System.out.println("Erreur lors du téléchargement: " + responseCode);
}

```

Avec Apache HttpClient

```
import org.apache.http.HttpEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;

import java.io.InputStream;

CloseableHttpClient httpClient = HttpClients.createDefault();
HttpGet httpGet = new HttpGet("http://tonserveur/api/download/test.txt");

try (CloseableHttpResponse response = httpClient.execute(httpGet)) {
    int statusCode = response.getStatusLine().getStatusCode();
    if (statusCode == 200) {
        HttpEntity entity = response.getEntity();
        if (entity != null) {
            InputStream inputStream = entity.getContent();
            // inputStream prêt à être utilisé
        }
    } else {
        System.out.println("Erreur lors du téléchargement: " + statusCode);
    }
}

```