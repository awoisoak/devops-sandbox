
CI/CD pipeline created with Github Actions for the [Camera Exposure Calculator]([https://github.com/awoisoak/photo-shop](https://github.com/awoisoak/Camera-Exposure-Calculator)) app. 
 ### ci.yaml
 This workflow will build and upload the corresponding artifacts for [each commit](https://github.com/awoisoak/Camera-Exposure-Calculator/actions/runs/3228411301) pushed to the repository.
<p align="center">
<img width="909" alt="artifact" src="https://user-images.githubusercontent.com/11469990/195252296-b1e41e42-b7a7-47c1-8733-f3815db47dee.png">
</p>


 ### google_play_deployment.yml.yaml

 This workflow allows the deployment of the app to [Google Play](https://play.google.com/store/apps/details?id=com.awoisoak.exposure) with a single interface.

<p align="center">
<img width="317" alt="deploy" src="https://user-images.githubusercontent.com/11469990/195251751-bc819862-ed0f-47bd-bef5-bedb16465bd2.png">
</p>

All sensible data for the deployments is kept within the Github Secrets including the base64 coding of the signing key which will decode during the process to be able to sign the app.
Using [Gradle Play Publisher](https://github.com/Triple-T/gradle-play-publisher) within the app code it will publish the app listing to the Google Play and will deploy a 10% rollout in the passed track.
Lastly will create a [Github Release](https://github.com/awoisoak/Camera-Exposure-Calculator/releases/tag/1.8) with the attached app bundle.
