import helmet from 'helmet';
import express from 'express';
import { json, urlencoded } from 'body-parser';
import compression from 'compression';

export default (): express.Application => {
  const app = express();
  app.set('trust proxy', true);
  app.use(helmet());
  app.use(urlencoded({ extended: true, limit: '1kb' }));
  app.use(json({ limit: '10kb' }));
  app.use(compression());

  app.use('*', (_, res) => res.status(404).send());
  return app;
};
