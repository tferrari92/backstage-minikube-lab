## Cluster setup

```bash
minikube start
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
kubectl port-forward -n argocd service/my-argo-cd-argocd-server  8080:443
```

## Install NVM
```bash

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
nvm install 18
nvm use 18
nvm alias default 18
```

## Install yarn
```bash
npm install --global yarn
yarn set version 1.22.19
yarn --version
yarn global add concurrently
```

## Download backstage
```bash
git clone git@github.com:backstage/backstage.git backstage
cd backstage
git checkout v1.13.2
```

## Create app
```bash
npx @backstage/create-app@latest
cd backstage-aatt/
```

## Edit backstage-aatt/app-config.yaml if you want and test it with:
```bash
yarn dev
```


<!-- Once backstage is running go to:
http://localhost:3000/catalog-import
Paste this:
https://github.com/backstage/backstage/blob/master/catalog-info.yaml -->


# Build container image
```bash
yarn install --frozen-lockfile
yarn tsc
yarn build:backend

docker image build . -f packages/backend/Dockerfile --tag tferrari92/backstage:20
docker push tferrari92/backstage:20
```


### Backstage needs github api token to access software catalog. Get one on github console.

When creating a personal access token on GitHub, you must select scopes to define the level of access for the token. The scopes required vary depending on your use of the integration: https://backstage.io/docs/integrations/github/locations/#token-scopes
Reading software components:
    repo        
Reading organization data:
    read:org
    read:user
    user:email
Publishing software templates:
    repo
    workflow (if templates include GitHub workflows)

```bash
echo "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" | base64
```

#### Copy output to bs-secret.yaml
https://github.com/backstage/backstagehttps://github.com/backstage/backstage/blob/master/catalog-info.yaml


# Kubernetes Plugin Installation
https://backstage.io/docs/features/kubernetes/installation/
```bash
yarn add --cwd packages/app @backstage/plugin-kubernetes
yarn add --cwd packages/backend @backstage/plugin-kubernetes-backend
```

### Edit file:
packages/app/src/components/catalog/EntityPage.tsx

add:
```ts
import { EntityKubernetesContent } from '@backstage/plugin-kubernetes';

// You can add the tab to any number of pages, the service page is shown as an
// example here
const serviceEntityPage = (
  <EntityLayout>
    {/* other tabs... */}
    <EntityLayout.Route path="/kubernetes" title="Kubernetes">
      <EntityKubernetesContent refreshIntervalMs={30000} />
    </EntityLayout.Route>
  </EntityLayout>
);
```

#### Create file
packages/backend/src/plugins/kubernetes.ts
```ts
import { KubernetesBuilder } from '@backstage/plugin-kubernetes-backend';
import { Router } from 'express';
import { PluginEnvironment } from '../types';
import { CatalogClient } from '@backstage/catalog-client';

export default async function createPlugin(
  env: PluginEnvironment,
): Promise<Router> {
  const catalogApi = new CatalogClient({ discoveryApi: env.discovery });
  const { router } = await KubernetesBuilder.createBuilder({
    logger: env.logger,
    config: env.config,
    catalogApi,
    permissions: env.permissions,
  }).build();
  return router;
}
```


#### Edit packages/backend/src/index.ts
```ts
// ..
import kubernetes from './plugins/kubernetes';

async function main() {
  // ...
  const kubernetesEnv = useHotMemoize(module, () => createEnv('kubernetes'));
  // ...
  apiRouter.use('/kubernetes', await kubernetes(kubernetesEnv));
```


#### Edit app-config.yaml
```ts
kubernetes:
 serviceLocatorMethod:
   type: 'multiTenant'
 clusterLocatorMethods:
   - type: 'config'
     clusters:
       - url: kubernetes.default.svc.cluster.local:443
         name: local
         authProvider: 'serviceAccount'
         skipTLSVerify: false
         skipMetricsLookup: true
```

```bash
yarn build:backend
docker image build . -f packages/backend/Dockerfile --tag tferrari92/backstage:5
docker push tferrari92/backstage:5
```


#### Change tag on deployment



#### Info interesante:
https://backstage.spotify.com/learn/backstage-for-all/software-catalog/4-modeling/
https://backstage.spotify.com/learn/standing-up-backstage/putting-backstage-into-action/8-integration/
https://backstage.spotify.com/learn/onboarding-software-to-backstage/onboarding-software-to-backstage/5-register-component/

#### Info datallada sobre objetos de tipo template:
https://backstage.io/docs/features/software-catalog/descriptor-format#kind-template
#### Aqui las acciones q puede hacer el template:
http://localhost:3000/create/actions
#### Para acciones q no existen default:
https://backstage.io/docs/features/software-templates/writing-custom-actions/
#### A note on RepoUrlPicker
In the template.yaml file of the template we created, you must have noticed ui:field: RepoUrlPicker in the spec.parameters field. This is known as Scaffolder Field Extensions.

These field extensions are used in taking certain types of input from users like GitHub repository URL, teams registered in catalog for the owners field, etc. Such field extensions can also be customized for your own organization. See https://backstage.io/docs/features/software-templates/writing-custom-field-extensions/

#### Aca hay ejemplos de templates:
https://github.com/backstage/software-templates

#### Software Templates at Spotify
At Spotify, we have dozens of Software Templates. We divide them into several disciples like Backend, Frontend, Data pipelines, etc. Inside Spotify, we also have stakeholder groups for Web, Backend, Data, etc. separately. These Software Templates are hosted on our internal GitHub enterprise, maintained and reviewed by the concerned experts in the discipline.

The Technical Architecture Group (TAG) at Spotify is the body responsible for reducing fragmentation by deciding on the various Backend, Frontend, Data frameworks to be used inside Spotify. Hence, new Software Templates with completely new frameworks are carefully discussed and reviewed.

Our Software Templates are fundamental to the concept of Golden Paths at Spotify. The Golden Path is the opinionated and supported way to build something (for example, build a backend service, put up a website, create a data pipeline). The Golden Path Tutorial is a step-by-step instructions that walks you through this opinionated and supported path.

The blessed tools — those on the Golden Path — are visualized in the Explore section of Backstage. Read more https://engineering.atspotify.com/2020/08/how-we-use-golden-paths-to-solve-fragmentation-in-our-software-ecosystem/


#### Component objects:
https://backstage.io/docs/features/software-catalog/descriptor-format/#overall-shape-of-an-entity





# Following this approach, no template will load in the UI if any one of those is broken!!!
  locations:
    - type: url
      target: https://github.com/tomasferrarisenda/backstage/blob/main/templates/all-templates.yaml
      rules:
        - allow: [Template]






# CAMBIAR GITHUB_TOKEN PARA Q USE VARIABLE DE ENTONRNO POR SERCRET. La imagen de tag 8 tiene el token hardcodeado



# BACKSTAGE
If the only change you've made is to the app-config.yaml (or other configuration files) and not to the application code itself, you don't necessarily need to run yarn build or yarn build:backend. The Docker image build process should copy the updated configuration files into the image.